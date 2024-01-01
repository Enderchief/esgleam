import esgleam/internal/fetch_esbuild

/// Installs `esbuild` (required to be run before building)    
/// Run with `gleam run -m esgleam/install`
pub fn main() {
  fetch_esbuild.fetch()
}
