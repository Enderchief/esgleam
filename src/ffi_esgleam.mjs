import { exec, spawn } from "node:child_process";

export function exec_shell(command, cwd) {
  if (typeof command === "string")
    exec(command, { cwd, encoding: "utf-8" }, (_, stdout, stderr) => {
      console.log(stdout);
      console.error(stderr);
    });
  else if (typeof command === "object") {
    command = command.toArray();
    spawn(command[0], command.slice(1), { cwd, stdio: "inherit" });
  }
}
