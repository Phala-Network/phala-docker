import { sleep } from "https://deno.land/x/sleep/mod.ts";

// TODO: Check current (the image contains) has initialized

// TODO: descending sort folders and find the latest handoverable pruntime
let previousPath: string | undefined = undefined;
for await (const dirEntry of Deno.readDir('/opt/pruntime/backups')) {
  // console.log(dirEntry);

  // TODO: check handoverable (initialized && synced && version). Q: how to deal with not synced?
  // TODO: if handoverable is equal to current, should exit
  previousPath = `/opt/pruntime/backups/${dirEntry.name}`;
}

if (previousPath === undefined) {
  console.log("No need to handover!");
  Deno.exit(0);
}

const previousBin = new Deno.Command(`${previousPath}/start_pruntime.sh`, {
  stdin: "piped",
  env: {
    "SKIP_AESMD": "1"
  }
});
const child = previousBin.spawn();

// Waiting old bin start, I'm thinking it's good to not get from api but just dump a file then pass to the new one?
await sleep(30)

const command = new Deno.Command(`/opt/pruntime/releases/current/gramine-sgx`, {
  args: [
    "pruntime",
    "--request-handover-from http://localhost:8000",
  ],
  cwd: "/opt/pruntime/releases/current"
});
const { code, stdout, stderr } = command.outputSync();

console.log(code);
console.log(new TextDecoder().decode(stdout));
console.log(new TextDecoder().decode(stderr));

// TODO: Copy checkpoint from previous

// TODO: Copy current to backups

console.log("Handover completed");

child.kill();
Deno.exit(0);