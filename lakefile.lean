import Lake
open System Lake DSL

package fswatch where
  version := v!"0.1.0"

lean_lib FSWatch

lean_exe fswatch_test where
  root := `Test

target inotify.o pkg : FilePath := do
  let oFile := pkg.buildDir / "c" / "inotify.o"
  let srcJob ← inputTextFile <| pkg.dir / "c" / "inotify.c"
  let weakArgs := #["-I", (← getLeanIncludeDir).toString]
  buildO oFile srcJob weakArgs #["-fPIC"] "cc" getLeanTrace

target rdcw.o pkg : FilePath := do
  let oFile := pkg.buildDir / "c" / "rdcw.o"
  let srcJob ← inputTextFile <| pkg.dir / "c" / "rdcw.c"
  let weakArgs := #["-I", (← getLeanIncludeDir).toString]
  buildO oFile srcJob weakArgs #["-fPIC"] "cc" getLeanTrace

extern_lib libleanfswatch pkg := do
  let inotify ← inotify.o.fetch
  let rdcw ← rdcw.o.fetch
  let name := nameToStaticLib "leanfswatch"
  buildStaticLib (pkg.staticLibDir / name) #[inotify, rdcw]
