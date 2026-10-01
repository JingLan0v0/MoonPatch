import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const root = path.resolve(import.meta.dirname, '..');
const cli = path.join(root, '_build', 'js', 'debug', 'build', 'cmd', 'main', 'main.js');
const version = fs.readFileSync(path.join(root, 'moon.mod'), 'utf8').match(/^version = "([^"]+)"/m)?.[1];
assert.ok(version);
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'moonpatch-cli-'));
const patchFile = path.join(tmp, 'patch.json');
const docFile = path.join(tmp, 'document.json');
function invoke(args, input) {
  const result = spawnSync(process.execPath, [cli, ...args], {
    cwd: root, input, encoding: 'utf8', maxBuffer: 2 * 1024 * 1024,
  });
  if (result.error) throw result.error;
  return result;
}
try {
  fs.writeFileSync(patchFile, '[{"op":"add","path":"/name","value":"月"}]');
  const stdin = invoke(['--compact', '-', patchFile], Buffer.from('\uFEFF{}'));
  assert.equal(stdin.status, 0);
  assert.deepEqual(JSON.parse(stdin.stdout), { name: '月' });

  fs.writeFileSync(docFile, '{}');
  fs.writeFileSync(patchFile, '[{"op":"replace","path":"/missing","value":1}]');
  const failed = invoke([docFile, patchFile]);
  assert.equal(failed.status, 2);
  assert.match(failed.stderr, /missing_path at operation 0/);

  fs.writeFileSync(patchFile, '[{"op":"remove","path":"/bad\\npath"}]');
  const escaped = invoke([docFile, patchFile]);
  assert.equal(escaped.status, 2);
  assert.equal(escaped.stderr.split('\n').length, 2);
  assert.match(escaped.stderr, /bad\\npath/);

  fs.writeFileSync(patchFile, '{broken');
  const invalid = invoke([docFile, patchFile]);
  assert.equal(invalid.status, 2);
  assert.match(invalid.stderr, /invalid_json/);

  fs.writeFileSync(patchFile, Buffer.from([0xc3, 0x28]));
  const invalidUtf8 = invoke([docFile, patchFile]);
  assert.equal(invalidUtf8.status, 2);
  assert.match(invalidUtf8.stderr, /patch io:/);

  const handle = fs.openSync(patchFile, 'w');
  try { fs.ftruncateSync(handle, 16 * 1024 * 1024 + 1); }
  finally { fs.closeSync(handle); }
  const large = invoke([docFile, patchFile]);
  assert.equal(large.status, 2);
  assert.match(large.stderr, /input exceeds 16 MiB/);

  const bothStdin = invoke(['-', '-']);
  assert.equal(bothStdin.status, 2);
  assert.equal(invoke(['--version']).stdout.trim(), version);
  assert.match(invoke(['--help']).stdout, new RegExp(`MoonPatch ${version}`));
} finally {
  fs.rmSync(tmp, { recursive: true, force: true });
}
console.log('PASS CLI: stdin, BOM, diagnostics, malformed input, size limit, version');
