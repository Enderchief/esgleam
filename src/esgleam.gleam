import gleam/io
import gleam/string
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string_builder.{append, append_builder, from_strings}
import simplifile
import esgleam/internal

/// Kind of output
pub type Kind {
  /// Executes the `main()` function in your entry point
  Script
  /// Only exports the code
  Library
}

/// Output format of generated JavaScript
pub type Format {
  /// ECMAScript module
  Esm
  /// CommonJS
  Cjs
  /// immediately-invoked function expression
  Iife
}

/// Config for esbuild
pub type Config {
  Config(
    /// Output directory
    outdir: String,
    /// List of entry points supplied
    entry_points: List(String),
    /// Output format for JavaScript. See [`Format`](#Format)   
    /// default `Esm`
    format: Format,
    /// Kind for output   
    /// default `Library`
    kind: Kind,
    /// default `False`
    minify: Bool,
    /// List of [target environments](https://esbuild.github.io/api/#target)   
    /// default `[]`
    target: List(String),
    /// The root directory for the dev server (run server when defined)   
    /// default `None`
    serve: Option(String),
    /// Generate sourcemap for JavaScript   
    /// default `False`
    sourcemap: Bool,
    /// Enable watchmode. Bundles files on change   
    /// Note: `gleam build` need to be run manually   
    /// default `False`
    watch: Bool,
    /// raw flags to pass to esbuild   
    /// default `""`
    raw: String,
  )
}

/// Start to create a build script   
/// ```gleam
/// > esbuild.new("./dist/static")
/// Config("./dist/static", ...)
/// ```
pub fn new(outdir path: String) -> Config {
  Config(
    outdir: path,
    entry_points: [],
    format: Esm,
    kind: Library,
    minify: False,
    target: [],
    serve: None,
    sourcemap: False,
    watch: False,
    raw: "",
  )
}

/// [Entry points](https://esbuild.github.io/api/#entry-points)   
/// Can be use multiple times
pub fn entry(config: Config, path: String) -> Config {
  Config(..config, entry_points: [path, ..config.entry_points])
}

/// Output format. see [`Format`](#format)
pub fn format(config: Config, format: Format) {
  Config(..config, format: format)
}

/// Kind for output. see [`Kind`](#kind)   
/// if set to `Script`, will ignore all entries except the first and will call its `main` function.
pub fn kind(config: Config, kind: Kind) {
  Config(..config, kind: kind)
}

/// [Target](https://esbuild.github.io/api/#target) for transpiled JavaScript.
/// Can be used mutiple times   
/// ```gleam
/// > esbuild.new("./dist/static")
/// > |> esbuild.target("es2020")
/// > |> esbuild.target("firefox110")
/// > |> esbuild.target("edge90")
/// ```
pub fn target(config: Config, target: String) {
  Config(..config, target: [target, ..config.target])
}

/// Create minified JavaScript
pub fn minify(config: Config, do_minify: Bool) {
  Config(..config, minify: do_minify)
}

/// Start a development server on http://127.0.0.1:8000 with `path` being `/`
pub fn serve(config: Config, dir path: String) {
  Config(..config, serve: Some(path))
}

// #TODO: Setup file watcher for all targets
/// Note: There is no file watcher for Gleam files so you have to manually run `gleam build` on change.
pub fn watch(config: Config, do_watch: Bool) {
  Config(..config, watch: do_watch)
}

/// Raw CLI argument to pass to esbuild
pub fn raw(config: Config, args: String) {
  Config(..config, raw: string.append(to: " ", suffix: args))
}

pub fn bundle(config: Config) {
  simplifile.create_directory_all(config.outdir)
  |> result.map(fn(_) { do_bundle(config) })
}

fn do_bundle(config: Config) {
  let entries_list =
    list.map(config.entry_points, fn(entry) {
      "./build/dev/javascript/"
      <> internal.get_project_name()
      <> "/"
      <> string.replace(entry, ".gleam", with: ".mjs")
    })

  let assert Ok(first_entry_rel) =
    list.first(config.entry_points)
    |> result.map(string.replace(_, ".gleam", with: ".mjs"))

  let script_path = {
    "./build/dev/javascript/"
    <> internal.get_project_name()
    <> "/"
    <> "gleam.main.mjs"
  }

  let entries = case config.kind {
    Script -> {
      let content =
        "import { main } from \"" <> "./" <> first_entry_rel <> "\";main?.();"
      let assert Ok(_) = simplifile.write(content, to: script_path)
      script_path
    }

    Library -> string.join(entries_list, with: " ")
  }

  let cmd =
    string_builder.from_string("./priv/package/bin/esbuild ")
    |> append(entries)
    |> append(" --bundle")
    |> append_builder(case config.kind {
      Script ->
        from_strings([
          " --outfile="
          <> config.outdir
          <> "/"
          <> internal.get_project_name()
          <> ".mjs",
        ])
      Library -> from_strings([" --outdir=", config.outdir])
    })
    |> if_true(config.minify, " --minify")
    |> if_true(config.watch, " --watch")
    |> append(" --format=")
    |> append(format_to_string(config.format))
    |> if_true(!list.is_empty(config.target), " --target=")
    |> append(string.join(config.target, with: ","))
    |> if_some(config.serve, flag: " --servedir=")
    |> append(config.raw)
    |> string_builder.to_string

  io.println("$ " <> cmd)

  let _ = case config.watch {
    True -> watch_gleam()
    False -> fn() { Nil }
  }

  internal.exec_shell(cmd, ".")
}

fn format_to_string(format: Format) {
  case format {
    Esm -> "esm"
    Cjs -> "cjs"
    Iife -> "iife"
  }
}

fn if_true(
  builder: string_builder.StringBuilder,
  predicate: Bool,
  value: String,
) -> string_builder.StringBuilder {
  case predicate {
    True -> value
    False -> ""
  }
  |> append(builder, _)
}

fn if_some(
  builder: string_builder.StringBuilder,
  option opt: Option(String),
  flag flag: String,
) -> string_builder.StringBuilder {
  case opt {
    Some(value) -> flag <> value
    None -> ""
  }
  |> append(builder, _)
}

@target(javascript)
@external(javascript, "./ffi_esgleam.mjs", "watch_gleam")
pub fn watch_gleam() -> fn() -> Nil

@target(erlang)
pub fn watch_gleam() -> fn() -> Nil {
  fn() { Nil }
}
