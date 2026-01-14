# lean-fswatch

[![CI](https://github.com/intgrah/lean-fswatch/actions/workflows/ci.yml/badge.svg)](https://github.com/intgrah/lean-fswatch/actions/workflows/ci.yml)

File system watching for Lean 4. Based on [hfsnotify](https://github.com/haskell-fswatch/hfsnotify).

## Platforms

- [x] Linux (inotify)
- [ ] Windows (ReadDirectoryChangesW)
- [ ] macOS (FSEvents)

## Usage

```lean
import FSWatch

FSWatch.Manager.withManager fun m => do
  let _ ← m.watchTree "src" fun event =>
    println!"{event.path}: {repr event.kind}"
  while true do
    -- Do things
    IO.sleep 1000
```
