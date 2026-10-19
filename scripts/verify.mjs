import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { isDeepStrictEqual } from 'node:util';

const root = path.resolve(import.meta.dirname, '..');
const localHome = path.resolve(root, '..', '.tools', 'moonjmes-toolchain');
const localMoon = path.join(localHome, 'bin', 'moon.exe');
const moon = process.env.MOON_BIN || (fs.existsSync(localMoon) ? localMoon : 'moon');
const env = { ...process.env };
if (moon === localMoon) env.MOON_HOME = localHome;
env.MOON_BIN = moon;

function run(command, args) {
  const result = spawnSync(command, args, { cwd: root, env, encoding: 'utf8' });
  if (result.status !== 0) {
    process.stderr.write(result.stdout || '');
    process.stderr.write(result.stderr || '');
    throw new Error(`${command} ${args.join(' ')} failed`);
  }
  return result.stdout;
}

run(moon, ['fmt', '--check']);
run(moon, ['check', '--target', 'js']);
process.stdout.write(run(moon, ['test', '--target', 'js']));
run(moon, ['info', '--target', 'js']);
run(moon, ['build', 'cmd/main', '--target', 'js']);
const libraryOutput = run(moon, ['run', 'examples/library', '--target', 'js']);
if (!isDeepStrictEqual(JSON.parse(libraryOutput), {
  value: { revision: 5 }, restored: { revision: 4 },
})) {
  throw new Error('public library example mismatch');
}
console.log('PASS public library API example');

const cli = path.join(root, '_build', 'js', 'debug', 'build', 'cmd', 'main', 'main.js');
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'moonpatch-receipt-'));
try {
  for (const name of ['service-config', 'release-queue', 'access-policy']) {
    const actual = JSON.parse(run(process.execPath, [cli, '--compact',
      `examples/${name}.json`, `examples/${name}.patch.json`]));
    const expected = JSON.parse(fs.readFileSync(path.join(root,
      `examples/${name}.expected.json`), 'utf8'));
    if (!isDeepStrictEqual(actual, expected)) throw new Error(`${name} mismatch`);
    const receipt = JSON.parse(run(process.execPath, [cli, '--compact', '--receipt',
      `examples/${name}.json`, `examples/${name}.patch.json`]));
    if (!isDeepStrictEqual(receipt.value, expected)) throw new Error(`${name} receipt mismatch`);
    const valuePath = path.join(temp, `${name}.result.json`);
    const undoPath = path.join(temp, `${name}.rollback.json`);
    fs.writeFileSync(valuePath, JSON.stringify(receipt.value));
    fs.writeFileSync(undoPath, JSON.stringify(receipt.rollback));
    const restored = JSON.parse(run(process.execPath, [cli, '--compact', valuePath, undoPath]));
    const original = JSON.parse(fs.readFileSync(path.join(root, `examples/${name}.json`), 'utf8'));
    if (!isDeepStrictEqual(restored, original)) throw new Error(`${name} rollback mismatch`);
    console.log(`PASS scenario and rollback: ${name}`);
  }
} finally {
  fs.rmSync(temp, { recursive: true, force: true });
}

process.stdout.write(run(process.execPath, ['scripts/cli-integration.mjs']));
process.stdout.write(run(process.execPath, ['scripts/conformance.mjs']));
console.log('PASS full MoonPatch verification');
