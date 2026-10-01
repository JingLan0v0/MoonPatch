///|
test "RFC 6901 root, empty tokens, and escape ordering" {
  let doc = @json.parse("{\"\":0,\"a/b\":1,\"m~n\":2,\"~1\":3}")
  assert_true(json_equal(pointer_get(doc, ""), doc))
  assert_true(json_equal(pointer_get(doc, "/"), @json.parse("0")))
  assert_true(json_equal(pointer_get(doc, "/a~1b"), @json.parse("1")))
  assert_true(json_equal(pointer_get(doc, "/m~0n"), @json.parse("2")))
  assert_true(json_equal(pointer_get(doc, "/~01"), @json.parse("3")))
  assert_eq(escape_pointer_token("a/b~c"), "a~1b~0c")
  let tokens = ["a/b", "~", ""]
  assert_eq(format_pointer(tokens), "/a~1b/~0/")
  assert_eq(parse_pointer(format_pointer(tokens)), tokens)
}

///|
test "invalid pointer escapes and array indexes have stable errors" {
  let doc = @json.parse("[10,20]")
  for path in ["#", "a", "/~", "/~2"] {
    let code = try {
      pointer_get(doc, path) |> ignore
      "none"
    } catch {
      PatchError(d) => d.code
    }
    assert_eq(code, "invalid_pointer")
  }
  for path in ["/01", "/-", "/2", "/2147483648"] {
    let code = try {
      pointer_get(doc, path) |> ignore
      "none"
    } catch {
      PatchError(d) => d.code
    }
    assert_true(code == "invalid_index" || code == "missing_path")
  }
}

///|
test "pointer token depth is bounded" {
  let mut path = ""
  for i = 0; i < 129; i = i + 1 {
    path += "/x"
  }
  let code = try {
    parse_pointer(path) |> ignore
    "none"
  } catch {
    PatchError(d) => d.code
  }
  assert_eq(code, "limit_exceeded")
}
