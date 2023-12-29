import simplifile
import esgleam/internal.{exec_shell}

const cmd = "curl -fsSL https://esbuild.github.io/dl/latest | sh"

/// Installs `esbuild` (required to be run before building)    
/// Run with `gleam run -m esgleam/install`
pub fn main() {
  let assert Ok(_) = simplifile.create_directory_all("./priv/bin")
  exec_shell(cmd, "./priv/bin")
}
