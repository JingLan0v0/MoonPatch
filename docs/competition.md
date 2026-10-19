# October 2026 competition requirements and status

Sources: [event page](https://moonbitlang.github.io/Hackathon2026/), [linked charter](https://bxup9uklfcb.feishu.cn/wiki/Dx4Bwd6D1i3GfHkajQCcF7SznEd), and the organizer's October rejection notice supplied by the participant on 2026-10-19. The participant reports the organizer now permits AI-written proposals; this update is participant-reported, not independently verified in a public announcement.

| Requirement / issue | Evidence and action |
|---|---|
| Real problem, clear direction, one-page Markdown proposal | Guarded undo for JSON Patch transactions, 工具库; review the desktop proposal. |
| Name, introduction, applicability, three complete use cases, core functions | In the proposal and executable `examples/`. |
| Original/migration/reference status | Disclose moonconfig's RFC 6902 implementation and MoonPatch's new rollback scope. No moonconfig code copied. |
| Valid public GitHub root URL and at least ten meaningful commits | Exact URL: https://github.com/JingLan0v0/MoonPatch. The organizer's latest notice prints it. Confirm remote SHA and history before resubmission. |
| MoonBit implementation, examples, tests, CI, license, provenance | Repository contains these; verify CI for the exact submitted SHA. |
| Mooncakes and fresh consumer | Verify actual 0.2.0 publication and consumer; 0.1.0 was previously published. |
| October resubmission | Organizer notice permits form edits through **2026-10-31**. Participant must edit and submit the form; a repository push alone does not resubmit. |
| Acceptance and financial support | Solely organizer decisions; technical checks do not guarantee them. |

The October rejection reason was: “RFC 6902 JSON Patch 核心与 forey217/moonconfig 重叠，申报未说明基于已有生态项目的扩展关系。” The change in scope and provenance disclosure directly address it. The project is not presented as the first MoonBit JSON Patch engine. See [comparison](moonconfig-comparison.md) and [evidence](acceptance.md).
