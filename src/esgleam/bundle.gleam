import esgleam
import esgleam/internal

/// Bundles {%project_name}.gleam as a library using ESM to the `./dist` directory.
pub fn main() {
  esgleam.new(outdir: "./dist")
  |> esgleam.entry(internal.get_project_name() <> ".gleam")
  |> esgleam.bundle
}
