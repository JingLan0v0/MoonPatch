///|
/// Small executable that uses the public package API without the CLI host.
fn main raise {
  let document = @json.parse("{\"revision\":4}")
  let patch = @json.parse(
    "[{\"op\":\"test\",\"path\":\"/revision\",\"value\":4},{\"op\":\"replace\",\"path\":\"/revision\",\"value\":5}]",
  )
  let receipt = @patch.apply_with_receipt(document, patch) catch {
    _ => fail("example patch must apply")
  }
  let restored = @patch.apply(receipt.value, receipt.rollback) catch {
    _ => fail("example rollback must apply")
  }
  println(
    Json::object(Map([("value", receipt.value), ("restored", restored)])).stringify(),
  )
}
