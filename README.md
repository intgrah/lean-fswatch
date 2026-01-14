# lean-fswatch

[![CI](https://github.com/intgrah/lean-fswatch/actions/workflows/ci.yml/badge.svg)](https://github.com/intgrah/lean-fswatch/actions/workflows/ci.yml)

File system watching for Lean 4

```lean
import FSWatch

FSWatch.Manager.withManager fun m => do
  let _ ← m.watchDir "." fun event => IO.println s!"{repr event}"
  for _ in [:100] do
    m.processEvents
    IO.sleep 100
```
