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

Related MoonBit projects and the October scope correction:

- [forey217/moonconfig](https://github.com/forey217/moonconfig) already
  implements RFC 6902 JSON Patch and RFC 6901 JSON Pointer, and also offers
  diff/replay and configuration merge workflows. The 0.1.0 MoonPatch core
  therefore overlaps an existing ecosystem project. The October organizer
  rejected the first proposal for failing to disclose this relationship.
  Its [`moon.mod`](https://github.com/forey217/moonconfig/blob/main/moon.mod)
  declares an MIT license.
  MoonPatch 0.2.0 retains its independently written standards engine, but its
  contest scope is now the **guarded rollback receipt** produced when applying
  a supplied patch. It can consume moonconfig-generated RFC 6902 patches;
  there is no moonconfig dependency or copied source code. See
  [the feature comparison](docs/moonconfig-comparison.md).

- [tiye/recollect](https://mooncakes.io/docs/tiye/recollect) computes and
  applies its own structural `PatchOp` format for state synchronization.
- [Freesia666/moonjsonpath](https://mooncakes.io/docs/Freesia666/moonjsonpath)
  includes JSONPath-oriented pointer/patch utilities.
- [moonbitstack/moonjson](https://mooncakes.io/docs/moonbitstack/moonjson)
  includes JSON Pointer and lists JSON Patch as future work.

The RFC 6902 operation set is a shared standard, not a novelty claim.
Descriptions of other projects reflect their public documentation checked on
2026-10-19; they are not claims that no other rollback implementation exists.
