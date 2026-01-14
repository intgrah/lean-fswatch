import FSWatch

open FSWatch

def main : IO UInt32 := do
  let dir ← IO.FS.createTempDir
  let mut passed := 0
  let mut failed := 0
  let events ← IO.mkRef #[]

  Manager.withManager fun m => do
    let stopListening ← m.watchDir dir (callback := fun e => events.modify (·.push e))

    IO.FS.writeFile (dir / "a.txt") "hello"
    IO.sleep 100

    IO.FS.writeFile (dir / "a.txt") "world"
    IO.sleep 100

    IO.FS.removeFile (dir / "a.txt")
    IO.sleep 100

    stopListening

  let evs ← events.get

  if evs.any (fun e => e.path.toString.endsWith "a.txt") then
    passed := passed + 1
  else
    failed := failed + 1

  if evs.any (fun e => e.kind == .added) then
    passed := passed + 1
  else
    failed := failed + 1

  if evs.any (fun e => e.kind == .removed) then
    passed := passed + 1
  else
    failed := failed + 1

  IO.FS.removeDirAll dir
  IO.println s!"{passed} passed, {failed} failed"
  return if failed > 0 then 1 else 0
