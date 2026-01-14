import FSWatch

open FSWatch

def main : IO UInt32 := do
  let dir ← IO.FS.createTempDir
  let events ← IO.mkRef #[]
  let mut passed := 0
  let mut failed := 0

  Manager.withManager fun m => do
    let _ ← m.watchDir dir (callback := fun e => events.modify (·.push e))

    IO.FS.writeFile (dir / "a.txt") "hello"
    IO.sleep 100

    IO.FS.writeFile (dir / "a.txt") "world"
    IO.sleep 100

    IO.FS.rename (dir / "a.txt") (dir / "b.txt")
    IO.sleep 100

    IO.FS.removeFile (dir / "b.txt")
    IO.sleep 100

  let evs ← events.get

  if evs.any (·.kind == .added) then
    passed := passed + 1
  else
    failed := failed + 1
    IO.eprintln "FAIL: added"

  if evs.any (·.kind == .modified) then
    passed := passed + 1
  else
    failed := failed + 1
    IO.eprintln "FAIL: modified"

  if evs.any (·.kind == .movedOut) then
    passed := passed + 1
  else
    failed := failed + 1
    IO.eprintln "FAIL: movedOut"

  if evs.any (·.kind == .movedIn) then
    passed := passed + 1
  else
    failed := failed + 1
    IO.eprintln "FAIL: movedIn"

  if evs.any (·.kind == .removed) then
    passed := passed + 1
  else
    failed := failed + 1
    IO.eprintln "FAIL: removed"

  IO.FS.removeDirAll dir
  println!"{passed} passed, {failed} failed"
  return if failed > 0 then 1 else 0
