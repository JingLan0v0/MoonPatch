///|
priv enum Edit {
  Add(Json)
  Remove
  Replace(Json)
}

///|
/// Compare JSON values by RFC 6902 value semantics, including numeric value
/// equality and object key order independence.
pub fn json_equal(left : Json, right : Json) -> Bool {
  match (left, right) {
    (Null, Null) | (True, True) | (False, False) => true
    (String(a), String(b)) => a == b
    (Number(a, ..), Number(b, ..)) => a == b
    (Array(a), Array(b)) => {
      if a.length() != b.length() {
        return false
      }
      for i = 0; i < a.length(); i = i + 1 {
        if !json_equal(a[i], b[i]) {
          return false
        }
      }
      true
    }
    (Object(a), Object(b)) => {
      if a.length() != b.length() {
        return false
      }
      for entry in a {
        match b.get(entry.0) {
          Some(value) if json_equal(entry.1, value) => ()
          _ => return false
        }
      }
      true
    }
    _ => false
  }
}

///|
/// Build a new JSON tree along one changed path. No input Map or Array is
/// mutated, so a failed multi-operation patch leaves the caller's tree intact.
fn edit_at(
  document : Json,
  tokens : Array[String],
  depth : Int,
  action : Edit,
  operation : Int,
  path : String,
) -> Json raise PatchError {
  if depth == tokens.length() {
    return match action {
      Add(value) | Replace(value) => value
      Remove =>
        patch_fail(
          "invalid_patch", operation, path, "removing the root has no JSON result",
        )
    }
  }
  let token = tokens[depth]
  let terminal = depth + 1 == tokens.length()
  match document {
    Object(fields) => {
      if terminal && !(action is Add(_)) && fields.get(token) is None {
        patch_fail(
          "missing_path", operation, path, "object member does not exist",
        )
      }
      let replacement = if terminal {
        None
      } else {
        match fields.get(token) {
          Some(child) =>
            Some(edit_at(child, tokens, depth + 1, action, operation, path))
          None =>
            patch_fail(
              "missing_path", operation, path, "object member does not exist",
            )
        }
      }
      let result : Map[String, Json] = Map([])
      for entry in fields {
        if entry.0 == token {
          if terminal {
            match action {
              Add(value) | Replace(value) => result[entry.0] = value
              Remove => ()
            }
          } else {
            match replacement {
              Some(value) => result[entry.0] = value
              None => ()
            }
          }
        } else {
          result[entry.0] = entry.1
        }
      }
      if terminal && action is Add(value) && fields.get(token) is None {
        result[token] = value
      }
      Json::object(result)
    }
    Array(items) => {
      let index = array_index(
        token,
        items.length(),
        terminal && action is Add(_),
        terminal && action is Add(_),
        operation,
        path,
      )
      let result : Array[Json] = []
      for i = 0; i < items.length(); i = i + 1 {
        if terminal && i == index {
          match action {
            Add(value) => {
              result.push(value)
              result.push(items[i])
            }
            Replace(value) => result.push(value)
            Remove => ()
          }
        } else if !terminal && i == index {
          result.push(
            edit_at(items[i], tokens, depth + 1, action, operation, path),
          )
        } else {
          result.push(items[i])
        }
      }
      if terminal && index == items.length() {
        match action {
          Add(value) => result.push(value)
          _ => ()
        }
      }
      Json::array(result)
    }
    _ => patch_fail("missing_path", operation, path, "path traverses a scalar")
  }
}

///|
fn required_string(
  fields : Map[String, Json],
  name : String,
  operation : Int,
) -> String raise PatchError {
  match fields.get(name) {
    Some(String(value)) => value
    _ =>
      patch_fail(
        "invalid_patch",
        operation,
        "",
        "operation needs string " + name,
      )
  }
}

///|
fn required_value(
  fields : Map[String, Json],
  operation : Int,
  path : String,
) -> Json raise PatchError {
  match fields.get("value") {
    Some(value) => value
    None =>
      patch_fail("invalid_patch", operation, path, "operation needs value")
  }
}

///|
fn is_proper_prefix(from : Array[String], destination : Array[String]) -> Bool {
  if from.length() >= destination.length() {
    return false
  }
  for i = 0; i < from.length(); i = i + 1 {
    if from[i] != destination[i] {
      return false
    }
  }
  true
}

///|
/// Apply all six RFC 6902 operations in order. On error, no result is
/// returned and the original Json value remains unchanged.
pub fn apply(document : Json, patch : Json) -> Json raise PatchError {
  guard patch is Array(operations) else {
    patch_fail("invalid_patch", -1, "", "patch must be an array")
  }
  if operations.length() > 4096 {
    patch_fail("limit_exceeded", -1, "", "patch exceeds 4096 operations")
  }
  let mut current = document
  for i = 0; i < operations.length(); i = i + 1 {
    guard operations[i] is Object(fields) else {
      patch_fail("invalid_patch", i, "", "operation must be an object")
    }
    let name = required_string(fields, "op", i)
    let path = required_string(fields, "path", i)
    let tokens = parse_pointer(path) catch {
      PatchError(d) => patch_fail(d.code, i, path, d.message)
    }
    current = match name {
      "add" =>
        edit_at(
          current,
          tokens,
          0,
          Add(required_value(fields, i, path)),
          i,
          path,
        )
      "remove" => edit_at(current, tokens, 0, Remove, i, path)
      "replace" =>
        edit_at(
          current,
          tokens,
          0,
          Replace(required_value(fields, i, path)),
          i,
          path,
        )
      "copy" | "move" => {
        let from_path = required_string(fields, "from", i)
        let from_tokens = parse_pointer(from_path) catch {
          PatchError(d) => patch_fail(d.code, i, from_path, d.message)
        }
        if name == "move" && is_proper_prefix(from_tokens, tokens) {
          patch_fail("invalid_patch", i, path, "cannot move into a descendant")
        }
        let value = get_tokens(current, from_tokens, i, from_path)
        let base = if name == "move" {
          if from_tokens == tokens {
            current
          } else {
            edit_at(current, from_tokens, 0, Remove, i, from_path)
          }
        } else {
          current
        }
        if name == "move" && from_tokens == tokens {
          base
        } else {
          edit_at(base, tokens, 0, Add(value), i, path)
        }
      }
      "test" => {
        let expected = required_value(fields, i, path)
        let actual = get_tokens(current, tokens, i, path)
        if !json_equal(actual, expected) {
          patch_fail("test_failed", i, path, "test value does not match")
        }
        current
      }
      _ => patch_fail("invalid_patch", i, path, "unknown operation: " + name)
    }
  }
  current
}

///|
/// Parse JSON text and apply a patch, reporting invalid JSON explicitly.
pub fn apply_json(
  document_text : String,
  patch_text : String,
) -> Json raise PatchError {
  let document = @json.parse(document_text) catch {
    _ => patch_fail("invalid_json", -1, "", "document is not valid JSON")
  }
  let patch = @json.parse(patch_text) catch {
    _ => patch_fail("invalid_json", -1, "", "patch is not valid JSON")
  }
  apply(document, patch)
}
