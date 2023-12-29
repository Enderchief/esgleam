import gleam/io
import gleam/string
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/result
import gleam/string_builder.{append}
import simplifile
import esgleam/internal

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
  let assert Ok(project_name) =
    simplifile.read("./gleam.toml")
    |> result.map(with: fn(file) {
      let assert Ok(re) = regex.from_string("name *= *\"(\\w[\\w_]*)\"")
      let assert Ok(match) =
        regex.scan(re, file)
        |> list.first

      let assert Ok(first_maybe) = list.first(match.submatches)
      let assert Some(name): Option(String) = first_maybe
      name
    })

  let entries =
    list.map(config.entry_points, fn(entry) {
      "./build/dev/javascript/"
      <> project_name
      <> "/"
      <> string.replace(entry, ".gleam", with: ".mjs")
    })
    |> string.join(with: " ")

  let cmd =
    string_builder.from_string("./priv/bin/esbuild ")
    |> append(entries)
    |> append(" --bundle")
    |> append(" --outdir=")
    |> append(config.outdir)
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
