# renovate ブランチ CI 修正設計

## 背景

`renovate` ブランチは依存関係更新用のブランチだが、`.github/workflows/test.yml` が古いままである。

- `actions/checkout@v3` が非推奨へ移行中
- `gleam-version: "0.32.0"` は `gleam.toml` の `gleam = ">= 1.12.0"` を満たさない
- `test/` ディレクトリが存在せず、`gleam test` が失敗する

## 目標

`renovate` ブランチで CI が最小限の修正で成功する状態にする。

## 変更内容

### 1. `.github/workflows/test.yml`

```yaml
      - uses: actions/checkout@v4
      - uses: erlef/setup-beam@v1
        with:
          otp-version: "26.0.2"
          gleam-version: "1.18.1"
          rebar3-version: "3"
```

- `actions/checkout` を v4 に更新
- `gleam-version` を 1.18.1 に更新（gleam.toml の制約を満たす）

### 2. `test/esgleam_test.gleam`（新規）

```gleam
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
```

- `gleam test` コマンドが成功するための smoke test を追加
- `gleeunit` を dev-dependencies に追加する必要がある

## 成功基準

1. `gleam build` が成功する
2. `gleam test` が成功する
3. `gleam format --check src test` が成功する
4. GitHub Actions の `test` workflow が成功する

## 影響範囲

- `.github/workflows/test.yml`
- `test/esgleam_test.gleam`（新規）
- `gleam.toml`（`gleeunit` 追加の場合）
- `manifest.toml`（`gleeunit` 追加の場合）

## リスク

- `gleeunit` の追加は依存関係を増やすが、Renovate の目的（依存関係の管理）と整合する
- `gleam-version` を 1.18.1 に固定すると、将来のメジャーアップデートで再び手動更新が必要
