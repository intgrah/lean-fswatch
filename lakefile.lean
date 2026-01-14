import Lake
open System Lake DSL

package fswatch

lean_lib FSWatch

lean_exe fswatch_test where
  root := `Test

target inotify_shim.o pkg : FilePath := do
  let oFile := pkg.buildDir / "c" / "inotify_shim.o"
  let srcJob ← inputTextFile <| pkg.dir / "c" / "inotify_shim.c"
  let weakArgs := #["-I", (← getLeanIncludeDir).toString]
  buildO oFile srcJob weakArgs #["-fPIC"] "cc" getLeanTrace

extern_lib libleanfswatch pkg := do
  let o ← inotify_shim.o.fetch
  let name := nameToStaticLib "leanfswatch"
  buildStaticLib (pkg.staticLibDir / name) #[o]
