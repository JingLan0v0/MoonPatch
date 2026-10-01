///|
/// Small executable that uses the public package API without the CLI host.
fn main raise {
  let document = @json.parse("{\"revision\":4}")
  let patch = @json.parse(
    "[{\"op\":\"test\",\"path\":\"/revision\",\"value\":4},{\"op\":\"replace\",\"path\":\"/revision\",\"value\":5}]",
  )
  let updated = @patch.apply(document, patch) catch {
    _ => fail("example patch must apply")
  }
  println(updated.stringify())
}
