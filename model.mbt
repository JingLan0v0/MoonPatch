///|
/// A stable diagnostic for invalid patches or paths.
pub(all) struct Diagnostic {
  code : String
  operation : Int
  path : String
  message : String
}

///|
pub(all) suberror PatchError {
  PatchError(Diagnostic)
}

///|
fn[T] patch_fail(
  code : String,
  operation : Int,
  path : String,
  message : String,
) -> T raise PatchError {
  raise PatchError({ code, operation, path, message, })
}

///|
pub fn version() -> String {
  "0.1.0"
}
