import simplifile
import esgleam/internal.{exec_shell}

const cmd = "curl -fsSL https://esbuild.github.io/dl/latest | sh"

/// Installs `esbuild` (required to be run before building)    
/// Run with `gleam run -m esgleam/install`
pub fn main() {
  let _ = simplifile.create_directory("./build/dev/bin")
  exec_shell(cmd, "./build/dev/bin")
}
