## 0.4.2 (2024-01-14)
- [`b7a1ab8`](https://github.com/Enderchief/esgleam/commit/b7a1ab8bbb89f89154981cd735b50411081933e8) Install esgleam automatically if not installed.

## 0.4.1 (2024-01-13)
- [`00069ae`](https://github.com/Enderchief/esgleam/commit/00069ae870f63d16c54bd6320225b62d28390309) Rename `fetch_version` to `fetch_from_version`. 
- [`00069ae`](https://github.com/Enderchief/esgleam/commit/00069ae870f63d16c54bd6320225b62d28390309) Add `fetch_latest` as shorthand for `fetch_from_version(platform.get_package_name(), _)`.

## 0.4.0 (2024-01-13)
- [`6b044f3`](https://github.com/Enderchief/esgleam/commit/6b044f3a494b595e2d16daf6f5a63219a587ce1e) Config option `Kind`. Select between `Script` (call the `main` function in the bundle) and `Library` (standard bundling).
- [`6b044f3`](https://github.com/Enderchief/esgleam/commit/6b044f3a494b595e2d16daf6f5a63219a587ce1e) `esgleam/app` CLI module to bundle with kind `Script`.
- [`37ce214`](https://github.com/Enderchief/esgleam/commit/37ce214c501d62e646b8e7e9f360d33362d609f2) Expose internal api for installing esbuild
- [`37ce214`](https://github.com/Enderchief/esgleam/commit/37ce214c501d62e646b8e7e9f360d33362d609f2) Expose internal api for selecting package version
- [`37ce214`](https://github.com/Enderchief/esgleam/commit/37ce214c501d62e646b8e7e9f360d33362d609f2) Downgrade `Thoas` to be compatable with `gleam_json`
