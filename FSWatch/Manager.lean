import FSWatch.Types
import FSWatch.INotify

namespace FSWatch

open System (FilePath)
open INotify (FD WD Mask RawEvent)

structure WatchState where
  wd : WD
  basePath : FilePath
  callback : EventCallback
  predicate : EventPredicate

structure Manager where
  fd : FD
  watches : IO.Ref (Array WatchState)

namespace Manager

private def convertEvent (basePath : FilePath) (raw : RawEvent) : Event :=
  let path : FilePath := if raw.name.isEmpty then basePath else basePath / raw.name
  let isDir : IsDirectory :=
    if Mask.isDir.isSet raw.mask then .directory else .file
  if Mask.create.isSet raw.mask then .added path isDir
  else if Mask.modify.isSet raw.mask then .modified path isDir
  else if Mask.delete.isSet raw.mask then .removed path isDir
  else if Mask.movedFrom.isSet raw.mask then .movedOut path isDir
  else if Mask.movedTo.isSet raw.mask then .movedIn path isDir
  else if Mask.attrib.isSet raw.mask then .attributes path isDir
  else if Mask.closeWrite.isSet raw.mask then .closeWrite path isDir
  else if Mask.deleteSelf.isSet raw.mask then .watchedDirRemoved basePath
  else if Mask.qOverflow.isSet raw.mask then .overflow
  else if Mask.ignored.isSet raw.mask then .unknown path "ignored"
  else .unknown path s!"mask={raw.mask}"

def create : IO Manager := do
  let fd ← INotify.init
  let watches ← IO.mkRef #[]
  return { fd, watches }

def stop (m : Manager) : IO Unit := do
  let ws ← m.watches.get
  for state in ws do
    try INotify.rmWatch m.fd state.wd catch _ => pure ()
  INotify.close m.fd

def watchDir (m : Manager) (path : FilePath)
    (predicate : EventPredicate := EventPredicate.all)
    (callback : EventCallback) : IO WD := do
  let absPath ← IO.FS.realPath path
  let wd ← INotify.addWatch m.fd absPath.toString Mask.fileChanges.val
  let state : WatchState := { wd, basePath := absPath, callback, predicate }
  m.watches.modify (·.push state)
  return wd

def unwatch (m : Manager) (wd : WD) : IO Unit := do
  INotify.rmWatch m.fd wd
  m.watches.modify (·.filter (·.wd != wd))

def processEvents (m : Manager) : IO Unit := do
  let rawEvents ← INotify.read m.fd
  let watches ← m.watches.get
  for raw in rawEvents do
    let wdKey : WD := raw.wd.toUInt32
    match watches.find? (·.wd == wdKey) with
    | some state =>
        let event := convertEvent state.basePath raw
        if state.predicate event then
          state.callback event
    | none => pure ()

def withManager (f : Manager → IO α) : IO α := do
  let m ← create
  try f m finally stop m

end Manager
end FSWatch
