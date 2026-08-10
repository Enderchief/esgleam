import esgleam
import gleam/option.{None}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn new_config_test() {
  esgleam.new("./dist")
  |> should.equal(esgleam.Config(
    autoinstall: False,
    outdir: "./dist",
    entry_points: [],
    format: esgleam.Esm,
    kind: esgleam.Library,
    minify: False,
    target: [],
    serve: None,
    sourcemap: False,
    platform: None,
    watch: False,
    raw: "",
  ))
}
