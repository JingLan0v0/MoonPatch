import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { isDeepStrictEqual } from 'node:util';

// Apache-2.0 upstream tests are vendored at the pinned revision below.
const revision = '2a928f9044aad35c74e2788d498bcf2c6b91adea';
const names = ['tests.json', 'spec_tests.json'];
const root = path.resolve(import.meta.dirname, '..');
const moon = process.env.MOON_BIN || 'moon';
const built = spawnSync(moon, ['build', 'cmd/main', '--target', 'js'], {
  cwd: root, encoding: 'utf8',
});
if (built.status !== 0) {
  process.stderr.write(built.stderr || built.stdout);
  process.exit(2);
}
const cli = path.join(root, '_build', 'js', 'debug', 'build', 'cmd', 'main', 'main.js');
const cache = path.join(root, 'testdata', 'json-patch-tests');

const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'moonpatch-case-'));
const docFile = path.join(scratch, 'doc.json');
const patchFile = path.join(scratch, 'patch.json');
let passed = 0;
let skipped = 0;
const failures = [];
try {
  for (const name of names) {
    const cases = JSON.parse(fs.readFileSync(path.join(cache, name), 'utf8'));
    for (const test of cases) {
      if (test.disabled || !('doc' in test) || !('patch' in test)) {
        skipped++;
        continue;
      }
      fs.writeFileSync(docFile, JSON.stringify(test.doc));
      fs.writeFileSync(patchFile, JSON.stringify(test.patch));
      const result = spawnSync(process.execPath, [cli, '--compact', docFile, patchFile], {
        cwd: root, encoding: 'utf8', maxBuffer: 8 * 1024 * 1024,
      });
      const expectedError = 'error' in test;
      let ok = false;
      if (expectedError) {
        ok = result.status === 2;
      } else if (result.status === 0) {
        try {
          ok = isDeepStrictEqual(JSON.parse(result.stdout), test.expected);
        } catch { /* malformed output is a failure */ }
      }
      if (ok) passed++;
      else failures.push({ file: name, comment: test.comment, doc: test.doc, patch: test.patch,
        expected: expectedError ? { error: test.error } : test.expected,
        actual: { status: result.status, stdout: result.stdout, stderr: result.stderr } });
    }
  }
} finally {
  fs.rmSync(scratch, { recursive: true, force: true });
}
console.log(`JSON Patch conformance: ${passed}/${passed + failures.length}; skipped ${skipped}`);
console.log(`Suite revision: ${revision}`);
if (failures.length) {
  console.error(JSON.stringify(failures.slice(0, 20), null, 2));
  process.exit(1);
}
