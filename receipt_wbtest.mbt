///|
test "receipt reverses an ordered transaction with overwrites and array edits" {
  let original = @json.parse(
    "{\"revision\":4,\"name\":\"old\",\"items\":[\"a\",\"b\"],\"copy\":null}",
  )
  let patch = @json.parse(
    "[{\"op\":\"test\",\"path\":\"/revision\",\"value\":4},{\"op\":\"add\",\"path\":\"/name\",\"value\":\"new\"},{\"op\":\"add\",\"path\":\"/items/-\",\"value\":\"c\"},{\"op\":\"add\",\"path\":\"/items/1\",\"value\":\"x\"},{\"op\":\"copy\",\"from\":\"/name\",\"path\":\"/copy\"},{\"op\":\"replace\",\"path\":\"/revision\",\"value\":5},{\"op\":\"remove\",\"path\":\"/items/0\"}]",
  )
  let receipt = apply_with_receipt(original, patch)
  assert_eq(receipt.value, apply(original, patch))
  assert_eq(apply(receipt.value, receipt.rollback), original)
  assert_eq(receipt.paths.length(), 6)
  guard receipt.rollback is Array(undo) else { fail("expected undo array") }
  assert_eq(undo.length(), 7)
}

///|
test "receipt safely reverses a move with array index shifts" {
  let original = @json.parse("{\"tasks\":[\"build\",\"test\",\"ship\"]}")
  let patch = @json.parse(
    "[{\"op\":\"move\",\"from\":\"/tasks/0\",\"path\":\"/tasks/2\"}]",
  )
  let receipt = apply_with_receipt(original, patch)
  assert_eq(
    receipt.value,
    @json.parse("{\"tasks\":[\"test\",\"ship\",\"build\"]}"),
  )
  assert_eq(apply(receipt.value, receipt.rollback), original)
  assert_eq(receipt.paths, ["/tasks/2", "/tasks/0"])
}

///|
test "rollback refuses to overwrite a changed result" {
  let original = @json.parse("{\"revision\":4,\"enabled\":false}")
  let patch = @json.parse(
    "[{\"op\":\"replace\",\"path\":\"/enabled\",\"value\":true}]",
  )
  let receipt = apply_with_receipt(original, patch)
  let changed = @json.parse("{\"revision\":5,\"enabled\":true}")
  let error = try {
    apply(changed, receipt.rollback) |> ignore
    None
  } catch {
    PatchError(diagnostic) => Some(diagnostic.code)
  }
  assert_eq(error, Some("test_failed"))
  assert_eq(changed, @json.parse("{\"revision\":5,\"enabled\":true}"))
}

///|
test "receipt preserves the original operation index on failure" {
  let original = @json.parse("{\"name\":\"before\"}")
  let patch = @json.parse(
    "[{\"op\":\"add\",\"path\":\"/name\",\"value\":\"after\"},{\"op\":\"remove\",\"path\":\"/missing\"}]",
  )
  let error = try {
    apply_with_receipt(original, patch) |> ignore
    None
  } catch {
    PatchError(diagnostic) => Some(diagnostic)
  }
  guard error is Some(diagnostic) else { fail("expected failure") }
  assert_eq(diagnostic.operation, 1)
  assert_eq(diagnostic.code, "missing_path")
  assert_eq(original, @json.parse("{\"name\":\"before\"}"))
}

///|
test "receipt reverses a root replacement and a no-op test" {
  let original = @json.parse("{\"a\":1}")
  let patch = @json.parse(
    "[{\"op\":\"test\",\"path\":\"/a\",\"value\":1},{\"op\":\"replace\",\"path\":\"\",\"value\":[1,2]}]",
  )
  let receipt = apply_with_receipt(original, patch)
  assert_eq(receipt.value, @json.parse("[1,2]"))
  assert_eq(apply(receipt.value, receipt.rollback), original)
}
