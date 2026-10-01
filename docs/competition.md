# October 2026 competition requirements and status

Checked on 2026-10-01 against the
[October event page](https://moonbitlang.github.io/Hackathon2026/) and its
[linked Feishu charter](https://bxup9uklfcb.feishu.cn/wiki/Dx4Bwd6D1i3GfHkajQCcF7SznEd).
The live submission form and organizer group notices still need participant
review before any application is sent.

| Requirement | Source / stage | Current evidence | Status / next action |
|---|---|---|---|
| Choose a real problem and one of the suggested directions | Event page / proposal | RFC 6902 patching; tool-library direction | Defined locally |
| One-page project description; applicant understands goal and path | Event page and charter / proposal | `docs/application-facts.md` contains facts and prompts | Participant must write and submit the actual application |
| At least three complete expected use cases | Charter / proposal | Three runnable examples with exact input, patch and expected output | Prepared |
| Application proposal must be written by a human | Charter / proposal | No AI-authored submission-ready proposal is provided | Participant action |
| Public GitHub repository and traceable, meaningful commits; charter says at least 10 valid commits | Event page and charter / proposal and completion | [Public repository](https://github.com/JingLan0v0/MoonPatch) and more than 10 substantive commits | Verify remote history and continue real development |
| MoonBit primary implementation, README, runnable examples and tests | Event page and charter / completion | MoonBit core, two READMEs, examples, unit and RFC suite | Locally verified |
| CI covering check, build and test | Charter / completion | Windows and Ubuntu [run 36865850203](https://github.com/JingLan0v0/MoonPatch/actions/runs/36865850203) passed on `722ff72` | Recheck latest submitted commit |
| Publish package to Mooncakes | Charter / completion | Module metadata prepared, not published | Requires authenticated account and fresh-consumer check |
| OSI license and provenance | Charter / completion | Apache-2.0 and third-party notices | Prepared |
| Join contest group and use GitHub ID as nickname | Event page / participant | No account evidence in this repository | Participant action |
| October at most three form submissions; team at most three people | Event page / submission | Not applicable to local code | Participant must observe |
| 150 yuan startup support after proposal approval; 350 yuan completion support after acceptance | Event page and charter / organizer | No October application or acceptance yet | Organizer decision |

**Deadline conflict:** The current event page says October registration and
acceptance close on **2026-10-31**, while the linked Feishu charter still
contains September 30 stage dates. Treat the event page as the current month
announcement, but confirm the controlling deadline in the contest group or
form before submitting; this repository does not silently replace charter
text. The event page says official charter and notices control details.

The charter also rejects repeated, split, or merely cosmetic resubmissions.
MoonPatch is a new RFC 6902 write/update component, separate from the earlier
MoonJMES RFC-compatible query engine. The shared JSON domain and adapted CLI
infrastructure are disclosed in `THIRD_PARTY_NOTICES.md`; the new MoonBit
patch engine and verification suite are the substantive work.
