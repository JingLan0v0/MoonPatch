# MoonPatch

[简体中文](README.zh-CN.md) | English

MoonPatch is a MoonBit library and file/stdin CLI for applying standard JSON
Patch documents. It implements [RFC 6902](https://www.rfc-editor.org/info/rfc6902/)
operations with [RFC 6901](https://www.rfc-editor.org/info/rfc6901/) JSON
Pointers. A configuration tool or API client can update selected JSON fields
without replacing an entire document or writing one-off traversal code.

The core is MoonBit. Node.js is used only for CLI file and process I/O. The
library does not mutate its input; if any operation fails, the caller gets a
structured error and no partial result. All **108 enabled tests** in the
pinned [json-patch-tests](https://github.com/json-patch/json-patch-tests)
suite pass locally; four upstream tests are marked disabled and are reported
separately. See [conformance details](docs/acceptance.md).

## Capabilities and boundaries

- `add`, `remove`, `replace`, `move`, `copy`, and `test`, in document order
- object member and array edits, including `-` append and index shifts
- pointer escaping (`~0`, `~1`), empty keys, and root selection
- JSON value equality for `test`, including `1` equal to `1.0` and object key
  order independence
- stable diagnostics with code, operation number, path, and message
- limits of 4,096 operations, 16,384 pointer characters, 128 pointer tokens,
  and 16 MiB per CLI input file

The initial release targets MoonBit's JS backend. It has no HTTP client,
schema validator, JSON diff generator, or nonstandard patch operators. Removing
the entire root is rejected because it cannot produce a JSON result. This is
a standalone standards-based patch format; it does not reuse the custom patch
model of [tiye/recollect](https://mooncakes.io/docs/tiye/recollect).

## Run it locally

Install MoonBit and Node.js 24, then from the project root:

```sh
moon run cmd/main --target js -- --compact examples/service-config.json examples/service-config.patch.json
```

This produces the JSON in `examples/service-config.expected.json`. Use `-`
for either document or patch input from stdin, but not both. On Windows,
`./scripts/moon.ps1` wraps a local or installed `moon` executable:

```powershell
.\scripts\moon.ps1 run cmd/main --target js -- examples/release-queue.json examples/release-queue.patch.json
```

The CLI writes only JSON to stdout on success. Errors go to stderr and exit
with status 2; it never rewrites the input files.

## Library API

Import `JingLan0v0/moonpatch` from a local checkout. The runnable
[`examples/library`](examples/library) package exercises the public API.
**The package has not yet
been published to Mooncakes; do not use `moon add` until publication is
verified.**

```moonbit
import {
  "JingLan0v0/moonpatch" @moonpatch,
  "moonbitlang/core/json",
}
```

```moonbit
let document = @json.parse("{\"revision\":4}")
let patch = @json.parse(
  "[{\"op\":\"test\",\"path\":\"/revision\",\"value\":4},{\"op\":\"replace\",\"path\":\"/revision\",\"value\":5}]",
)
let updated = @moonpatch.apply(document, patch)
```

Public entry points are `apply`, `apply_json`, `pointer_get`,
`parse_pointer`, `format_pointer`, `escape_pointer_token`, `json_equal`, and
`version`.

## Demonstrations and verification

Three checked examples are in [`examples`](examples): service configuration,
release queue ordering, and access policy edits. The full local verification
command runs formatting, checking, unit tests, those examples, real CLI
process tests, and the vendored RFC test suite:

```sh
node scripts/verify.mjs
```

The GitHub Actions workflow is prepared for Ubuntu and Windows but has no
remote run until this project is published in a public repository. Design,
known limits, provenance, and contest status are in [`docs`](docs).

## License

Apache-2.0. Upstream test vectors are redistributed under the same license;
see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
