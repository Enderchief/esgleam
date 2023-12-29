# esgleam

[![Package Version](https://img.shields.io/hexpm/v/esgleam)](https://hex.pm/packages/esgleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/esgleam/)

*esbuild for Gleam that works on Erlang & JavaScript.*

## Quick start

1. Create a Gleam project as you would normally.

2. Install `esbuild` (*note*: you will have to rerun this if your build directory gets wiped. i.e. after `gleam clean`)
```sh
$ gleam run -m esgleam/install
```

3. Create `/src/build.gleam` with the following
```gleam
import esgleam

pub fn main() {
   esgleam.new("./dist/static")
   |> esgleam.entry("main.gleam")
   |> esgleam.target("esnext")
   |> esgleam.target("firefox110")
   |> esgleam.bundle
}
```

4. Build for JavaScript
```sh
$ gleam build --target=javascript
```

5. Run your build script (in any target)
```sh
$ gleam run -m build
```

## Installation

If available on Hex this package can be added to your Gleam project:

```sh
gleam add esgleam
```

and its documentation can be found at <https://hexdocs.pm/esgleam>.

## Roadmap
- [ ] Create file watcher for `*.gleam` which runs on both Erlang and JavaScript
- [ ] Fix bug with STDOUT/STDERR not being shown when running `esbuild` in the erlang target
- [ ] Write tests for config options
- [ ] Add more config options if needed
- [ ] Pseudo-SourceMaps until [#1341](https://github.com/gleam-lang/gleam/discussions/1341) merges
- [ ] Consider creating a way to use plugins
- [ ] Hot Module Reloading?????
