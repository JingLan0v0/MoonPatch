///|
fn usage() -> String {
  "MoonPatch " +
  @patch.version() +
  "\nUsage: moon run cmd/main --target js -- [--compact] DOCUMENT PATCH\nUse - for one input from stdin. Both inputs cannot be -.\n"
}

///|
fn run() -> Int raise {
  let args : Array[String] = []
  for value in arguments() {
    args.push(value)
  }
  if args.length() == 1 && (args[0] == "--help" || args[0] == "-h") {
    write_stdout(usage())
    return 0
  }
  if args.length() == 1 && args[0] == "--version" {
    write_stdout(@patch.version() + "\n")
    return 0
  }
  let mut compact = false
  let paths : Array[String] = []
  for arg in args {
    if arg == "--compact" {
      compact = true
    } else if arg.has_prefix("--") {
      write_stderr("moonpatch: unknown option: " + arg + "\n")
      return 2
    } else {
      paths.push(arg)
    }
  }
  if paths.length() != 2 || (paths[0] == "-" && paths[1] == "-") {
    write_stderr("moonpatch: expected DOCUMENT and PATCH; use - at most once\n")
    return 2
  }
  let source = read_utf8(paths[0])
  if source[0] != "" {
    write_stderr("moonpatch: document io: " + source[0] + "\n")
    return 2
  }
  let patch = read_utf8(paths[1])
  if patch[0] != "" {
    write_stderr("moonpatch: patch io: " + patch[0] + "\n")
    return 2
  }
  let result = @patch.apply_json(source[1], patch[1])
  write_stdout(result.stringify(indent=if compact { 0 } else { 2 }) + "\n")
  0
}

///|
fn main {
  let status = run() catch {
    @patch.PatchError(d) => {
      write_stderr(
        "moonpatch: " +
        d.code +
        " at operation " +
        d.operation.to_string() +
        " path " +
        Json::string(d.path).stringify() +
        ": " +
        Json::string(d.message).stringify() +
        "\n",
      )
      2
    }
    _ => {
      write_stderr("moonpatch: unexpected error\n")
      2
    }
  }
  set_exit(status)
}
