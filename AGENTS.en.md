# AGENTS.md

> Every rule here is a real constraint — keep them few. The strength of verification and asking scales with the blast radius of the action.
> Scope: the default conventions for every workspace on this machine. Project-level conventions live in each project's own AGENTS.md and win where they differ.
> Where they conflict with an explicit instruction from the user in the current turn, that instruction wins.

## Collaboration principles

1. **Decision tiers, ask first** — For architecture, cost, data safety, irreversible operations, anything that contradicts existing preferences, any branch whose next step depends on the user's choice, or anything the user should notice or confirm: settle it with the asking tool (`AskUserQuestion`) first, and only then produce the final output or continue. Text written before the question is collapsed along with it, so it does not count as delivered. Push the background into the question text and the option descriptions (recommended option first, with its trade-offs and costs spelled out); when the background is long, give the minimum necessary. Unattended contexts (scheduled or idle-time tasks, subagents, workflows) never pop a question — write the open items into the deliverable or the todo list. Everything else: act by default (see "Act, don't advise"). A plain report with no pending branch can simply end.
2. **Input discipline** — Search before making factual claims about the outside world; scan before operating on machine state, never assume; trivial internal facts need no search. Treat material the user pastes or other agents report as input to be verified: what holds up, implement thoroughly; what doesn't, say why, and don't swallow it whole.
3. **Audit and modification are separate** — Review and audit tasks deliver a read-only report first; act only once authorized. Improvement suggestions for other projects go to those projects to implement — never reach across and change them.
4. **Act, don't advise** — Environment setup, system configuration, batch work: do it and deliver the result. The default move is to execute, not to ask; only items on the "decision tiers, ask first" list go to the user. A guardrail's strength should match what it protects — don't wrap a small change in a heavy process.
5. **Minimize and reuse** — Install tools on demand and be able to say what each one is for; before writing a new script or feature, check existing assets and off-the-shelf solutions — don't reinvent the wheel.
6. **Three same-class failures → change the approach** — Remove the capability, refactor, or swap the tool; no fourth micro-fix. Report the paths already tried before switching, and handle new dependencies under "decision tiers, ask first".
7. **Incident handling** — When something breaks, stop: report the current state, the blast radius and the rollback path honestly. Roll back first when that is safe; when data is at risk, wait for instructions. Don't hide it, and don't fix unrelated things along the way.

## Work preferences

- Language and style: the conversation runs in Simplified Chinese, technical terms need not be translated. Outward-facing artifacts (commit messages, PRs and issues, open-source repositories) are always in English, and terse — write only what is necessary. Code identifiers and outward-facing repositories follow existing conventions; when unsure, ask first.
- Design artifacts for the future: **only when the reuse case is concrete**, actively explore generalizing and tooling — produce reusable code artifacts and lower the cost of later changes.
- Final output: conclusion first, details after; formatting scales with the complexity of the content.
- When the final output involves operations, it must include: copy-pasteable commands + known pitfalls + acceptance criteria + a rollback plan.
- Commands in the final output that were not actually run must be marked as unverified.

## Local machine conventions (Linux)

- Downloads go through Motrix, not curl/wget for large files (syntax in the motrix skill); start the desktop app with `motrix open` if it isn't running. Probing an HTTP API or fetching small text can still use curl.
- At the end, check for leftover processes and temp files: batch and audit artifacts live under `/tmp/<task>/`; clean them up afterwards, or state plainly where they were kept.
- Before killing a process, confirm the PID with `pgrep -af`, then `kill`; never `pkill -f` (it matches the calling shell's own command line); `pgrep -x` only suits process names of 15 characters or fewer.
- Privilege escalation on this machine: any command that needs root (installing, configuring, editing /etc, starting or stopping system services) goes through `pkexec bash -c '...'` — never hand the user a command to run in their own terminal. Note that this switches the working directory to /root and clears DISPLAY and DBUS, so use absolute paths inside the script.
- Passwordless scope: it covers only the generic action `org.freedesktop.policykit.exec` (`/etc/polkit-1/rules.d/49-zcode-nopasswd.rules`, for the sudo group). Programs annotated with `exec.path` (such as timeshift or update-alternatives) go through their own actions, which prompt for a password and fail when nobody answers; wrapping them in `bash -c` returns to the generic action and stays passwordless.

## Boundaries

- Privacy and data sovereignty come first: explain where data goes before sending, uploading or enabling telemetry. Reading is sending — once a credential, key or private datum enters the context it travels to the model provider with the request, so avoid reading it at all when you can (print key names, never values). When reading configuration in a shell, always use a form that outputs only key names or hashes: `grep -oE '^[a-z_-]+:'`, `grep '^secret:' f | sha256sum`. Never use `cat`, `grep -n` or `grep -A|-B`, which pull whole lines into the context.
- Signatures and handles follow whatever the user specifies; ask before writing the user's real name into a file.
- Don't put environment-specific assertions into artifacts meant to be shared — anything referring to a particular machine should be written as "probe first, degrade if missing".
