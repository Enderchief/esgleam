@target(javascript)
import gleam/string

@target(erlang)
type Charlist

@target(javascript)
pub fn exec_shell(command: String, cwd: String) -> Nil {
  case string.contains(command, contain: "|") {
    True -> do_exec_shell(command, cwd)
    False -> do_exec_shell_list(string.split(command, on: " "), cwd)
  }
}

@target(javascript)
@external(javascript, "../ffi_esgleam.mjs", "exec_shell")
pub fn do_exec_shell(command: String, cwd: String) -> Nil

@target(javascript)
@external(javascript, "../ffi_esgleam.mjs", "exec_shell")
pub fn do_exec_shell_list(command: List(String), cwd: String) -> Nil

@target(erlang)
@external(erlang, "unicode", "characters_to_list")
fn characters_to_list(chacters: String) -> Charlist

@target(erlang)
@external(erlang, "os", "cmd")
fn os_cmd(command: Charlist) -> Nil

@target(erlang)
pub fn exec_shell(command: String, cwd: String) -> Nil {
  characters_to_list("cd " <> cwd <> ";" <> command)
  |> os_cmd
  Nil
}
