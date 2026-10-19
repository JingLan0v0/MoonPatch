# MoonPatch

[简体中文](README.zh-CN.md) | English · [GitHub](https://github.com/JingLan0v0/MoonPatch) · [Mooncakes](https://mooncakes.io/docs/JingLan0v0/moonpatch)

MoonPatch is a MoonBit library and CLI for **reversible JSON Patch transactions**. Given a JSON document and an [RFC 6902](https://www.rfc-editor.org/info/rfc6902/) patch, `apply_with_receipt` returns the new value, affected paths, and a standard RFC 6902 rollback patch. The rollback begins with a `test` of the exact result: if anything changed since the receipt was created, undo fails without changing the caller's document.

Version 0.1.0 implemented the six standard patch operations and [RFC 6901](https://www.rfc-editor.org/info/rfc6901/) pointers. **These are existing ecosystem functionality**, including in [forey217/moonconfig](https://github.com/forey217/moonconfig). Version 0.2.0 adds an operation-aware, guarded rollback workflow for patches supplied by a caller or configuration tool. MoonPatch can consume a patch produced by moonconfig; it does not copy moonconfig's source or implement its diff and merge workflow. See [ecosystem comparison](docs/moonconfig-comparison.md) and [provenance](THIRD_PARTY_NOTICES.md).

## Try a reversible change

Install MoonBit and Node.js 24, then run from the repository root:

```sh
moon run cmd/main --target js -- --compact --receipt examples/service-config.json examples/service-config.patch.json
```

The output has `value` (updated JSON), `rollback` (standard patch with a leading `test`) and `paths` (affected pointers). Save `value` and `rollback` as separate JSON files, then run `moon run cmd/main --target js -- --compact value.json rollback.json` to restore the original. `--receipt` is optional; without it the CLI emits only the updated document. On Windows, `./scripts/moon.ps1` wraps a local or installed `moon` executable.

Public APIs: `apply_with_receipt(document, patch) -> PatchReceipt`, `apply(document, patch) -> Json`, `apply_with_receipt_json(document_text, patch_text)`, `apply_json`, RFC 6901 pointer helpers and structured diagnostics. [`examples/library`](examples/library) executes a change and rollback using only the public API. Module name: `JingLan0v0/moonpatch`; see [Mooncakes](https://mooncakes.io/docs/JingLan0v0/moonpatch) for published versions.

## Behavior and limits

- Forward patches support `add`, `remove`, `replace`, `move`, `copy`, and `test` in order, including array insertion, `-` append, root replacement, and escaped pointer tokens.
- Input JSON is immutable from the caller's perspective. Failure reports `PatchError` with code, operation index, path, and message; no partial result is returned.
- Rollback steps run in reverse order. For `move`, the smallest shared ancestor is restored to account for index shifts; receipts can be larger than forward patches.
- Maximum 4,096 operations for `apply` and 4,095 for `apply_with_receipt` (one slot is needed for the guard). Pointers are limited to 16,384 characters and 128 tokens. CLI inputs are limited to 16 MiB each; in-memory output and receipt size are not bounded by that input limit.
- The current target is MoonBit JS. Node.js handles only CLI file/stdin/stdout. There is no diff generator, merge engine, JSON Schema validator, HTTP client, or deletion of the entire root.

The root `test` checks JSON value equality, not provenance, caller identity, or an external concurrency lock. Persistent or concurrent systems still need their own storage transaction and authorization policy.

## Reproducible evidence

Run `node scripts/verify.mjs` for formatting, compilation, unit tests, the public library example, three CLI scenarios with round-trip rollback, CLI process tests, and the pinned [json-patch-tests](https://github.com/json-patch/json-patch-tests) suite. All 108 enabled upstream cases pass locally; four disabled upstream cases are reported separately. The three scenarios cover service configuration, release ordering, and access policy. [GitHub Actions](https://github.com/JingLan0v0/MoonPatch/actions/workflows/ci.yml) runs on Windows and Ubuntu. Results for a specific commit are recorded in [acceptance evidence](docs/acceptance.md).

Apache-2.0. See [third-party notices](THIRD_PARTY_NOTICES.md) for test-vector and infrastructure provenance.
