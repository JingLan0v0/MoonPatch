# October application facts (2026-10-19)

- Name: MoonPatch; direction: 工具库 / reusable developer component.
- Repository: https://github.com/JingLan0v0/MoonPatch; module: `JingLan0v0/moonpatch`.
- Version 0.1.0 independently implemented RFC 6902/RFC 6901. The organizer rejected the first proposal because its core overlaps [forey217/moonconfig](https://github.com/forey217/moonconfig) and the application did not explain that relationship.
- Version 0.2.0 adds `apply_with_receipt`: updated value, touched paths, and a standard rollback patch whose first operation tests the expected post-state. `move` reverses via the smallest common ancestor to handle array shifts.
- moonconfig documents patch, diff/replay, and merge. MoonPatch consumes a supplied patch and generates a guarded rollback receipt. No moonconfig source was copied; this is not a migration. See [comparison](moonconfig-comparison.md).
- Three executable scenarios: service configuration, release queue, access policy. Each has input, forward patch, expected output, and verified rollback.
- Apache-2.0. Pinned third-party test vectors and reused CLI infrastructure are disclosed in [notices](../THIRD_PARTY_NOTICES.md).
- The participant reports that AI-written proposals are now permitted. The participant must review the final form; only the organizer can approve it.
