///|
/// Decode an RFC 6901 JSON Pointer. The empty string selects the root.
/// URI fragment identifiers such as `#/a` are intentionally not accepted.
pub fn parse_pointer(path : String) -> Array[String] raise PatchError {
  let chars = path.to_array()
  if chars.length() > 16384 {
    patch_fail("limit_exceeded", -1, path, "pointer exceeds 16384 characters")
  }
  if chars.length() == 0 {
    return []
  }
  if chars[0] != '/' {
    patch_fail(
      "invalid_pointer", -1, path, "pointer must be empty or start with /",
    )
  }
  let tokens : Array[String] = []
  let mut token : Array[Char] = []
  let mut i = 1
  while i < chars.length() {
    match chars[i] {
      '/' => {
        if tokens.length() >= 128 {
          patch_fail("limit_exceeded", -1, path, "pointer exceeds 128 tokens")
        }
        tokens.push(String::from_array(token))
        token = []
      }
      '~' => {
        if i + 1 >= chars.length() {
          patch_fail("invalid_pointer", -1, path, "incomplete ~ escape")
        }
        i += 1
        match chars[i] {
          '0' => token.push('~')
          '1' => token.push('/')
          _ => patch_fail("invalid_pointer", -1, path, "invalid ~ escape")
        }
      }
      value => token.push(value)
    }
    i += 1
  }
  if tokens.length() >= 128 {
    patch_fail("limit_exceeded", -1, path, "pointer exceeds 128 tokens")
  }
  tokens.push(String::from_array(token))
  tokens
}

///|
/// Escape one object key for inclusion in a JSON Pointer.
pub fn escape_pointer_token(token : String) -> String {
  let escaped : Array[Char] = []
  for c in token {
    match c {
      '~' => {
        escaped.push('~')
        escaped.push('0')
      }
      '/' => {
        escaped.push('~')
        escaped.push('1')
      }
      _ => escaped.push(c)
    }
  }
  String::from_array(escaped)
}

///|
fn array_index(
  token : String,
  length : Int,
  allow_end : Bool,
  allow_dash : Bool,
  operation : Int,
  path : String,
) -> Int raise PatchError {
  if allow_dash && token == "-" {
    return length
  }
  let chars = token.to_array()
  if chars.length() == 0 || (chars.length() > 1 && chars[0] == '0') {
    patch_fail("invalid_index", operation, path, "array index is not canonical")
  }
  let mut value = 0
  for c in chars {
    if c < '0' || c > '9' {
      patch_fail(
        "invalid_index", operation, path, "array index must be decimal",
      )
    }
    let digit = c.to_int() - '0'.to_int()
    if value > 214748364 || (value == 214748364 && digit > 7) {
      patch_fail("invalid_index", operation, path, "array index overflows")
    }
    value = value * 10 + digit
  }
  if value > length || (!allow_end && value == length) {
    patch_fail("missing_path", operation, path, "array index is out of bounds")
  }
  value
}

///|
fn get_tokens(
  document : Json,
  tokens : Array[String],
  operation : Int,
  path : String,
) -> Json raise PatchError {
  let mut current = document
  for token in tokens {
    match current {
      Object(fields) =>
        match fields.get(token) {
          Some(value) => current = value
          None =>
            patch_fail(
              "missing_path", operation, path, "object member does not exist",
            )
        }
      Array(items) => {
        let index = array_index(
          token,
          items.length(),
          false,
          false,
          operation,
          path,
        )
        current = items[index]
      }
      _ =>
        patch_fail("missing_path", operation, path, "path traverses a scalar")
    }
  }
  current
}

///|
/// Retrieve the value selected by an RFC 6901 pointer.
pub fn pointer_get(document : Json, path : String) -> Json raise PatchError {
  get_tokens(document, parse_pointer(path), -1, path)
}
