import gleam/regex
import gleam/result
import gleam/list
import gleam/io
import gleam/option.{type Option, Some}
import simplifile
import gleam/string

@target(erlang)
type Charlist

@target(javascript)
pub fn exec_shell(command: String, cwd: String) -> Nil {
  do_exec_shell(string.split(command, on: " "), cwd)
}

@target(javascript)
@external(javascript, "../ffi_esgleam.mjs", "exec_shell")
pub fn do_exec_shell(command: List(String), cwd: String) -> Nil

@target(erlang)
@external(erlang, "unicode", "characters_to_list")
fn characters_to_list(chacters: String) -> Charlist

@target(erlang)
@external(erlang, "os", "cmd")
fn os_cmd(command: Charlist) -> Nil

@target(erlang)
@external(erlang, "ffi_esgleam", "do_exec")
fn exec_erl(cmd: String, args: List(String)) -> a

@target(erlang)
pub fn exec_shell(command: String, cwd: String) -> Nil {
  let [cmd, ..args] =
    string.split(command, on: " ")
    |> io.debug
  // characters_to_list("cd " <> cwd <> ";" <> command)
  exec_erl(cmd, args)
  |> io.debug
  Nil
}

pub fn get_project_name() -> String {
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
  project_name
}
