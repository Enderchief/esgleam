import gleam/io
import gleam/string
import esgleam/mod/platform

const base_url = "https://registry.npmjs.org/{#version}/latest"

@target(erlang)
@external(erlang, "ffi_esgleam", "do_fetch")
fn do_fetch(url: String) -> Nil

@target(javascript)
@external(javascript, "../../ffi_esgleam.mjs", "do_fetch")
fn do_fetch(url: String, then: fn() -> Nil) -> Nil

@target(erlang)
/// installs esbuild and take in a callback to run post install
pub fn fetch_from_version(version: String, then callback: fn() -> Nil) {
  let url = string.replace(base_url, "{#version}", version)
  io.println("Fetching esbuild from: " <> url)
  do_fetch(url)
  callback()
}

@target(javascript)
/// installs esbuild and take in a callback to run post install
pub fn fetch_from_version(version: String, then callback: fn() -> Nil) {
  let url = string.replace(base_url, "{#version}", version)
  io.println("Fetching esbuild from: " <> url)
  do_fetch(url, callback)
}

pub fn fetch_latest(then callback: fn() -> Nil) {
  fetch_from_version(platform.get_package_name(), callback)
}

pub fn fetch() {
  fetch_latest(fn() { io.println("Installed esbuild") })
  Nil
}
