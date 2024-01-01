import { exec, spawn } from 'node:child_process';
import { chmod, mkdir, writeFile } from 'node:fs/promises';
import * as process from 'node:process';
import {
    Win32,
    Linux,
    Darwin,
    Solaris,
    Freebsd,
    Openbsd,
    Arm,
    Arm64,
    Ia32,
    Ppc64,
    X64,
// @ts-expect-error
} from './esgleam/internal/platform.mjs';
// @ts-expect-error
import { Ok, Error } from './gleam.mjs';

import { entries } from './streaming_tar.mjs';

export function exec_shell(command, cwd) {
  if (typeof command === 'string')
    exec(command, { cwd, encoding: 'utf-8' }, (_, stdout, stderr) => {
      console.log(stdout);
      console.error(stderr);
    });
  else if (typeof command === 'object') {
    command = command.toArray();
    spawn(command[0], command.slice(1), { cwd, stdio: 'inherit' });
  }
}

/** @type {Partial<Record<NodeJS.Platform, () => import('./esgleam/internal/platform.gleam').OsName$>>} */
const platform_map = {
  darwin: () => new Darwin(),
  freebsd: () => new Freebsd(),
  linux: () => new Linux(),
  openbsd: () => new Openbsd(),
  sunos: () => new Solaris(),
  win32: () => new Win32(),
};

export function get_os() {
  const platform = process.platform;
  const res = platform_map[platform]();
  if (res) return new Ok(res);
  return new Error(res);
}

/** @type {Partial<Record<NodeJS.Architecture, () => import('./esgleam/internal/platform.gleam').Arch$>>} */
const arch_map = {
  arm: () => new Arm(),
  arm64: () => new Arm64(),
  ia32: () => new Ia32(),
  ppc64: () => new Ppc64(),
  x64: () => new X64(),
};

export function get_arch() {
  const arch = process.arch;
  const res = arch_map[arch]();
  if (res) return new Ok(res);
  return new Error(res);
}

/**
 * @param {string} url
 */
export async function do_fetch(url) {
  const info_res = await fetch(url);
  if (!info_res.ok)
    return console.error(
      `Oh no. Something went wrong. Error fetching "${url}"\n${await info_res.text()}`
    );
  const content = await info_res.json();
  const tarball_url = content.dist.tarball;
  console.log(`Fetching tarball from: ${tarball_url}`);
  const tarResp = await fetch(tarball_url);
  const tarStream = tarResp.body.pipeThrough(new DecompressionStream('gzip'));

  for await (const entry of entries(tarStream)) {
    if (entry.name == 'package/bin/esbuild') {
        console.log(entry.name);
      try {
        await mkdir('./priv/package/bin', { recursive: true });
      } catch {}
      await writeFile(
        './priv/package/bin/esbuild',
        Buffer.from(await entry.arrayBuffer()),
        { encoding: 'binary' }
      );
      await chmod('./priv/package/bin/esbuild', 0o777);
      break;
    }
  }
}
