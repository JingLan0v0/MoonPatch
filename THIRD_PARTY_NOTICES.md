# Third-party notices and provenance

MoonPatch's RFC 6901 pointer and RFC 6902 patch engine are independently
implemented in MoonBit from the public specifications. No source code from
another JSON Patch implementation is included.

`testdata/json-patch-tests/tests.json` and `spec_tests.json` are copied from
[json-patch/json-patch-tests](https://github.com/json-patch/json-patch-tests)
at commit `2a928f9044aad35c74e2788d498bcf2c6b91adea`. The upstream README
states Copyright 2014 The Authors and licenses the tests under Apache-2.0.
The project's [LICENSE](LICENSE) contains the Apache-2.0 license text.
Four upstream tests are marked disabled and are explicitly excluded by the
conformance runner.

The CLI host I/O adapter and pinned Windows CI installer were adapted from
the author's earlier [MoonJMES](https://github.com/JingLan0v0/moonbit-jmespath)
project, also Apache-2.0. They are infrastructure; the patch engine is a new
project with a different public API and standard.

Related MoonBit projects considered at scope selection:

- [tiye/recollect](https://mooncakes.io/docs/tiye/recollect) computes and
  applies its own structural `PatchOp` format for state synchronization.
- [Freesia666/moonjsonpath](https://mooncakes.io/docs/Freesia666/moonjsonpath)
  includes JSONPath-oriented pointer/patch utilities.
- [moonbitstack/moonjson](https://mooncakes.io/docs/moonbitstack/moonjson)
  includes JSON Pointer and lists JSON Patch as future work.

MoonPatch's boundary is the six-operation RFC 6902 wire format, strict RFC
6901 addressing, atomic error behavior, and repeatable compatibility testing.
The ecosystem search was performed on 2026-10-01 and must be repeated before
submission; it is not a claim that no competing project exists.
