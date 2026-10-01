# Architecture

```text
JSON document + RFC 6902 operation array
             |          |
             |      validate op / parse RFC 6901 pointer
             |          |
             +---- immutable path reconstruction ----> new JSON value
                                |
                         structured PatchError
```

`pointer.mbt` validates and decodes pointer tokens. It scans escapes in one
pass so `~01` becomes the literal token `~1`; decoding `~0` and `~1` with
unordered string replacements would be incorrect. Array indexes must be
canonical decimal numbers; `-` is only accepted for the final destination
of an `add` operation.

`patch.mbt` validates each operation, reads required fields, and applies it
to the current immutable JSON tree. Edits rebuild only the containers on the
selected path. Existing maps and arrays are read, never mutated. A `move`
reads its source, removes it, then adds the value to the destination against
the post-removal tree; moving into a descendant is rejected. `test` compares
JSON values recursively, including numeric equality and object member order
independence.

The public `apply` call either returns the final JSON or raises `PatchError`.
There is no visible partial result after failure. `apply_json` first parses
both JSON texts and reports malformed input separately. All core logic is
MoonBit. `cmd/main` is the only Node.js I/O adapter; it reads no more than
16 MiB plus one probe byte per file and uses strict UTF-8 decoding.

## Limits and explicit exclusions

The patch array is capped at 4,096 operations. Each pointer is capped at
16,384 Unicode scalar characters and 128 tokens. These limits bound parser
and edit recursion. The current API does not impose a total node or output
byte budget on an in-memory `Json` supplied by a library caller; callers
handling untrusted, large values should apply their own document-size policy.
The CLI's per-input 16 MiB limit is not a bound on the size of a constructed
output. It does not write patched documents back to disk.

The first release does not generate diffs, process HTTP requests, validate
JSON Schema, support URI fragment pointer syntax, or support a non-JSON root
deletion result. These boundaries keep RFC 6902 behavior testable.
