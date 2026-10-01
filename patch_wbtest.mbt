///|
test "all six RFC 6902 operations apply in order" {
  let document = @json.parse(
    "{\"items\":[\"a\",\"b\"],\"meta\":{\"owner\":\"Ada\"}}",
  )
  let patch = @json.parse(
    "[{\"op\":\"test\",\"path\":\"/meta/owner\",\"value\":\"Ada\"},{\"op\":\"add\",\"path\":\"/items/1\",\"value\":\"x\"},{\"op\":\"replace\",\"path\":\"/meta/owner\",\"value\":\"Lin\"},{\"op\":\"copy\",\"from\":\"/meta/owner\",\"path\":\"/meta/reviewer\"},{\"op\":\"move\",\"from\":\"/items/0\",\"path\":\"/items/-\"},{\"op\":\"remove\",\"path\":\"/items/0\"}]",
  )
  let actual = apply(document, patch)
  let expected = @json.parse(
    "{\"items\":[\"b\",\"a\"],\"meta\":{\"owner\":\"Lin\",\"reviewer\":\"Lin\"}}",
  )
  assert_true(json_equal(actual, expected))
  assert_true(
    json_equal(
      document,
      @json.parse("{\"items\":[\"a\",\"b\"],\"meta\":{\"owner\":\"Ada\"}}"),
    ),
  )
}

///|
test "root replacement, escaped object keys, and numeric equality" {
  let patch = @json.parse(
    "[{\"op\":\"test\",\"path\":\"/a~1b\",\"value\":1.0},{\"op\":\"add\",\"path\":\"/~0\",\"value\":null},{\"op\":\"replace\",\"path\":\"\",\"value\":[1,2]}]",
  )
  assert_true(
    json_equal(apply(@json.parse("{\"a/b\":1}"), patch), @json.parse("[1,2]")),
  )
}

///|
test "failure is atomic and identifies the failing operation" {
  let original = @json.parse("{\"count\":1}")
  let patch = @json.parse(
    "[{\"op\":\"replace\",\"path\":\"/count\",\"value\":2},{\"op\":\"test\",\"path\":\"/count\",\"value\":3}]",
  )
  let error = try {
    apply(original, patch) |> ignore
    None
  } catch {
    PatchError(d) => Some(d)
  }
  guard error is Some(d) else {
    assert_true(false)
    return
  }
  assert_eq(d.code, "test_failed")
  assert_eq(d.operation, 1)
  assert_true(json_equal(original, @json.parse("{\"count\":1}")))
}

///|
test "move cannot enter its own child and array indexes are post-removal" {
  let invalid = @json.parse(
    "[{\"op\":\"move\",\"from\":\"/a\",\"path\":\"/a/b\"}]",
  )
  let source = @json.parse("{\"a\":{\"b\":1}}")
  let code = try {
    apply(source, invalid) |> ignore
    "none"
  } catch {
    PatchError(d) => d.code
  }
  assert_eq(code, "invalid_patch")
  let moved = apply(
    @json.parse("[\"a\",\"b\",\"c\"]"),
    @json.parse("[{\"op\":\"move\",\"from\":\"/0\",\"path\":\"/2\"}]"),
  )
  assert_true(json_equal(moved, @json.parse("[\"b\",\"c\",\"a\"]")))
}

///|
test "invalid operation shape, missing parent, and root removal fail" {
  for
    patch_text in [
      "{}", "[{}]", "[{\"op\":\"add\",\"path\":\"/x\"}]", "[{\"op\":\"add\",\"path\":\"/x/y\",\"value\":1}]",
      "[{\"op\":\"remove\",\"path\":\"\"}]",
    ] {
    let patch = @json.parse(patch_text)
    let source = @json.parse("{}")
    let failed = try {
      apply(source, patch) |> ignore
      false
    } catch {
      PatchError(_) => true
    }
    assert_true(failed)
  }
}
