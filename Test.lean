import FSWatch

open FSWatch

def main : IO UInt32 := do
  let dir ← IO.FS.createTempDir
  let mut passed := 0
  let mut failed := 0
  let events ← IO.mkRef #[]

  Manager.withManager fun m => do
    let callback : EventCallback := fun e => events.modify (·.push e)
    let _ ← Manager.watchDir m dir EventPredicate.all callback

    IO.FS.writeFile (dir / "a.txt") "hello"
    IO.sleep 50
    Manager.processEvents m

    IO.FS.writeFile (dir / "a.txt") "world"
    IO.sleep 50
    Manager.processEvents m

    IO.FS.removeFile (dir / "a.txt")
    IO.sleep 50
    Manager.processEvents m

  let evs ← events.get
  let paths := evs.filterMap Event.path

  if paths.any (·.toString.endsWith "a.txt") then
    passed := passed + 1
  else
    failed := failed + 1

  if evs.any (fun | .added .. => true | _ => false) then
    passed := passed + 1
  else
    failed := failed + 1

  if evs.any (fun | .removed .. => true | _ => false) then
    passed := passed + 1
  else
    failed := failed + 1

  IO.FS.removeDirAll dir
  IO.println s!"{passed} passed, {failed} failed"
  return if failed > 0 then 1 else 0
