import gleam/io
import gleam/string
import esgleam/internal/platform

const base_url = "https://registry.npmjs.org/{#version}/latest"

@external(erlang, "ffi_esgleam", "do_fetch")
@external(javascript, "../../ffi_esgleam.mjs", "do_fetch")
fn do_fetch(url: String) -> Nil

pub fn fetch() {
  let version = platform.get_package_name()
  let url = string.replace(base_url, "{#version}", version)
  io.println("Fetching esbuild from: " <> url)
  do_fetch(url)
  Nil
}
