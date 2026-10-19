///|
/// A successful transaction and a guarded RFC 6902 patch that reverses it.
/// The rollback's first operation tests the entire result, so it refuses to
/// overwrite a document that has changed since this receipt was produced.
pub(all) struct PatchReceipt {
  value : Json
  rollback : Json
  paths : Array[String]
}

///|
fn receipt_op(name : String, path : String) -> Json {
  Json::object(Map([("op", Json::string(name)), ("path", Json::string(path))]))
}

///|
fn receipt_value_op(name : String, path : String, value : Json) -> Json {
  Json::object(
    Map([
      ("op", Json::string(name)),
      ("path", Json::string(path)),
      ("value", value),
    ]),
  )
}

///|
fn receipt_parent(tokens : Array[String]) -> Array[String] {
  let parent : Array[String] = []
  for i = 0; i + 1 < tokens.length(); i = i + 1 {
    parent.push(tokens[i])
  }
  parent
}

///|
fn receipt_common_parent(
  source : Array[String],
  destination : Array[String],
) -> Array[String] {
  let common : Array[String] = []
  let length = Int::min(source.length(), destination.length())
  for i = 0; i < length; i = i + 1 {
    if source[i] != destination[i] {
      break
    }
    common.push(source[i])
  }
  common
}

///|
/// Generate one inverse operation for one already validated forward step.
/// Move restores its smallest shared ancestor: reversing two edits to the
/// same array using only their original indexes is not generally correct.
fn receipt_inverse(
  before : Json,
  operation : Map[String, Json],
  index : Int,
) -> Json? raise PatchError {
  let name = required_string(operation, "op", index)
  let path = required_string(operation, "path", index)
  let tokens = parse_pointer(path)
  match name {
    "test" => None
    "replace" =>
      Some(
        receipt_value_op(
          "replace",
          path,
          get_tokens(before, tokens, index, path),
        ),
      )
    "remove" =>
      Some(
        receipt_value_op("add", path, get_tokens(before, tokens, index, path)),
      )
    "add" | "copy" => {
      if tokens.length() == 0 {
        return Some(receipt_value_op("replace", "", before))
      }
      let parent_tokens = receipt_parent(tokens)
      let parent_path = format_pointer(parent_tokens)
      let parent = get_tokens(before, parent_tokens, index, parent_path)
      match parent {
        Object(fields) =>
          match fields.get(tokens[tokens.length() - 1]) {
            Some(previous) => Some(receipt_value_op("replace", path, previous))
            None => Some(receipt_op("remove", path))
          }
        Array(items) => {
          let last = tokens[tokens.length() - 1]
          let inverse_path = if last == "-" {
            parent_path + "/" + items.length().to_string()
          } else {
            path
          }
          Some(receipt_op("remove", inverse_path))
        }
        _ => patch_fail("missing_path", index, path, "path traverses a scalar")
      }
    }
    "move" => {
      let source = required_string(operation, "from", index)
      let source_tokens = parse_pointer(source)
      if source_tokens == tokens {
        return None
      }
      let common = receipt_common_parent(source_tokens, tokens)
      let common_path = format_pointer(common)
      Some(
        receipt_value_op(
          "replace",
          common_path,
          get_tokens(before, common, index, common_path),
        ),
      )
    }
    _ => patch_fail("invalid_patch", index, path, "unknown operation")
  }
}

///|
/// Apply an RFC 6902 patch and create an operation-aware rollback receipt.
/// The receipt supports at most 4095 input operations because its rollback
/// needs one additional guard operation within the 4096-operation limit.
pub fn apply_with_receipt(
  document : Json,
  patch : Json,
) -> PatchReceipt raise PatchError {
  guard patch is Array(operations) else {
    patch_fail("invalid_patch", -1, "", "patch must be an array")
  }
  if operations.length() > 4095 {
    patch_fail("limit_exceeded", -1, "", "receipt exceeds 4095 operations")
  }
  let mut current = document
  let inverses : Array[Json] = []
  let paths : Array[String] = []
  for i = 0; i < operations.length(); i = i + 1 {
    guard operations[i] is Object(fields) else {
      patch_fail("invalid_patch", i, "", "operation must be an object")
    }
    let name = required_string(fields, "op", i)
    let path = required_string(fields, "path", i)
    let single = Json::array([operations[i]])
    let next = apply(current, single) catch {
      PatchError(diagnostic) =>
        patch_fail(diagnostic.code, i, diagnostic.path, diagnostic.message)
    }
    match receipt_inverse(current, fields, i) {
      Some(inverse) => inverses.push(inverse)
      None => ()
    }
    if name != "test" {
      paths.push(path)
      if name == "move" {
        paths.push(required_string(fields, "from", i))
      }
    }
    current = next
  }
  let rollback : Array[Json] = [receipt_value_op("test", "", current)]
  for i = inverses.length(); i > 0; i = i - 1 {
    rollback.push(inverses[i - 1])
  }
  { value: current, rollback: Json::array(rollback), paths, }
}

///|
/// Serialize a receipt for CLI users without introducing a second patch
/// format. `rollback` is an ordinary RFC 6902 patch for `apply`.
pub fn receipt_json(receipt : PatchReceipt) -> Json {
  let paths : Array[Json] = []
  for path in receipt.paths {
    paths.push(Json::string(path))
  }
  Json::object(
    Map([
      ("value", receipt.value),
      ("rollback", receipt.rollback),
      ("paths", Json::array(paths)),
    ]),
  )
}

///|
pub fn apply_with_receipt_json(
  document_text : String,
  patch_text : String,
) -> Json raise PatchError {
  let document = @json.parse(document_text) catch {
    _ => patch_fail("invalid_json", -1, "", "document is not valid JSON")
  }
  let patch = @json.parse(patch_text) catch {
    _ => patch_fail("invalid_json", -1, "", "patch is not valid JSON")
  }
  receipt_json(apply_with_receipt(document, patch))
}
