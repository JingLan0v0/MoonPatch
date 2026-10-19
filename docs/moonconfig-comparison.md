# Relationship to forey217/moonconfig

Checked against [moonconfig's public repository](https://github.com/forey217/moonconfig)
and [Mooncakes documentation](https://mooncakes.io/docs/forey217/moonconfig@0.2.0)
on 2026-10-19. The October organizer explicitly found the original MoonPatch
RFC 6902 core overlapping moonconfig; we agree and disclose that overlap.

| Capability | moonconfig public documentation | MoonPatch 0.2.0 |
|---|---|---|
| RFC 6901 pointers and six RFC 6902 operations | Yes | Yes; shared standard foundation, not claimed as novel |
| Configuration diff, replay, three-way merge/conflict workflow | Yes | No |
| Apply caller-supplied patch and return new value | Yes | Yes |
| Return a standard inverse patch alongside the result | Not listed in its public README/API | Yes, `apply_with_receipt` |
| Refuse rollback if the post-state has changed | Not listed in its public README/API | Yes, rollback begins with root `test` |
| Expose touched paths with rollback receipt | Not listed in its public README/API | Yes, `PatchReceipt.paths` |

moonconfig's documented `guarded_diff` tests the **original base** before
applying a forward patch. MoonPatch's rollback tests the **result** before
undoing that patch. Both checks matter at different points in a change
lifecycle. The proposed integration is conceptual and format-based; there is
no direct dependency or integration adapter in this repository.

MoonPatch is an independent implementation, not a fork or migration of
moonconfig. No moonconfig source was copied. Its intended complementary use is
to apply and retain a rollback for an RFC 6902 patch from moonconfig or any
other producer. These statements describe documented APIs checked on the date
above, not a claim that moonconfig or another library can never add similar
features. See [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).
