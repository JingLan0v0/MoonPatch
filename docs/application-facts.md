# Applicant fact sheet and self-writing prompts

**This is a fact sheet, not a submission-ready proposal.** The linked Feishu
charter explicitly says the application must be written by the participant
and fit within one Markdown page. Write the final wording yourself after
running the project and checking each claim.

Verified facts for the form:

- Working name: MoonPatch; suggested direction: 工具库.
- Problem: apply ordered, portable partial updates to JSON documents using
  RFC 6902 instead of application-specific mutation code.
- Deliverable: MoonBit library plus file/stdin CLI; six standard operations,
  RFC 6901 pointers, immutable/atomic application, structured diagnostics.
- Three demonstrated cases: service configuration revision guard, release
  queue insertion/move, access-policy copy/remove/replacement. Each has three
  JSON files under `examples/`.
- Tests: eight MoonBit unit tests, CLI process checks, three scenarios, and
  108/108 enabled upstream conformance cases at a pinned commit.
- Boundaries: JS target, no diff generation or HTTP integration, 4,096 ops,
  128 pointer segments, 16 MiB per CLI input.
- Existing work: `tiye/recollect` uses a custom structural patch format;
  `moonjsonpath` has JSONPath-oriented pointer/patch utilities. MoonPatch
  focuses on the interoperable RFC 6902 wire format and atomic failure.
- Provenance: original patch engine; vendored Apache-2.0 tests; CLI host and
  CI installer adapted from the entrant's Apache-2.0 MoonJMES project.
- Present status: local project and local tests complete; GitHub publication,
  CI, Mooncakes release and October organizer review are **not complete**.

Prompts to answer in your own words:

1. What specific JSON update did you personally need, and why was replacing
   the whole document inconvenient or risky?
2. Why does RFC 6902 interoperability matter for MoonBit users, and how is
   this different from the related modules above?
3. Which three examples can you explain end to end, including input,
   patch, output, and the failure that `test` prevents?
4. Why did you choose immutable path reconstruction and strict errors? What
   happens to the original document when the second operation fails?
5. Which features are deliberately excluded from the first release, and why?
