namespace FSWatch

open System (FilePath)

inductive IsDirectory
  | file
  | directory
deriving Repr, BEq, Inhabited

inductive Event
  | added (path : FilePath) (isDir : IsDirectory)
  | modified (path : FilePath) (isDir : IsDirectory)
  | removed (path : FilePath) (isDir : IsDirectory)
  | movedOut (path : FilePath) (isDir : IsDirectory)
  | movedIn (path : FilePath) (isDir : IsDirectory)
  | attributes (path : FilePath) (isDir : IsDirectory)
  | closeWrite (path : FilePath) (isDir : IsDirectory)
  | watchedDirRemoved (path : FilePath)
  | overflow
  | unknown (path : FilePath) (info : String)
deriving Repr

namespace Event

def path : Event → Option FilePath
  | added p _
  | modified p _
  | removed p _
  | movedOut p _
  | movedIn p _
  | attributes p _
  | closeWrite p _
  | watchedDirRemoved p
  | unknown p _ => some p
  | overflow => none

def isDirectory : Event → Option IsDirectory
  | added _ d
  | modified _ d
  | removed _ d
  | movedOut _ d
  | movedIn _ d
  | attributes _ d
  | closeWrite _ d => some d
  | _ => none

end Event

abbrev EventCallback := Event → IO Unit
abbrev EventPredicate := Event → Bool
def EventPredicate.all : EventPredicate := fun _ => true

end FSWatch
