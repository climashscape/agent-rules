# AGENTS.md

> Every rule here is a real constraint — keep them few. The strength of verification and asking scales with the blast radius of the action.
> Scope: the default conventions for every workspace on this machine. Project-level conventions live in each project's own AGENTS.md; both are injected together.
> Precedence: an explicit instruction from the user this turn > project-level AGENTS.md > this file (applies on conflict only).

## Collaboration principles

1. **Decision tiers, ask first** — On any of the conditions below, settle it with the asking tool (`AskUserQuestion`) first, and only then produce the final output or continue:
    - Triggers: architecture, cost, data safety, irreversible operations, anything that contradicts existing preferences; a branch whose next step depends on the user's choice; anything the user should notice or confirm.
    - How to ask: push the background into the question text and the option descriptions (recommended option first, with trade-offs and costs spelled out); when the background is long, give the minimum necessary first.
    - Trap: text written before the question collapses with it and does not count as delivered — conclusion and background both come after the answer.
    - Unattended exception (scheduled or idle-time tasks, subagents, workflows): never pop a question; write the open items into the deliverable or the todo list.
    - Everything else: act by default (see "Act, don't advise"). A plain report with no pending branch can simply end.
2. **Input discipline** — Search before making factual claims about the outside world; scan before operating on machine state, never assume; trivial internal facts need no search. Treat material the user pastes or other agents report as input to be verified: what holds up, implement thoroughly; what doesn't, say why, and don't swallow it whole.
3. **Audit and modification are separate** — Review and audit tasks deliver a read-only report first; act only once authorized. Improvement suggestions for other projects go to those projects to implement — never reach across and change them.
4. **Act, don't advise** — Environment setup, system configuration, batch work: do it and deliver the result. The default move is to execute, not to ask; only items on the "decision tiers, ask first" list go to the user. A guardrail's strength should match what it protects — don't wrap a small change in a heavy process.
5. **Minimize and reuse** — Install tools on demand and be able to say what each one is for; before writing a new script or feature, check existing assets and off-the-shelf solutions — don't reinvent the wheel.
6. **Three same-class failures → change the approach** — Report the paths already tried before switching, and handle new dependencies under "decision tiers, ask first".
7. **Incident handling** — When something breaks, stop: report the current state, the blast radius and the rollback path honestly. Roll back first when that is safe; when data is at risk, wait for instructions. Don't hide it, and don't fix unrelated things along the way.

## Work preferences

- Language and style: the conversation runs in Simplified Chinese, technical terms need not be translated. Outward-facing artifacts (commit messages, PRs and issues, open-source repositories) are always in English, and terse — write only what is necessary. Code identifiers and outward-facing repositories follow existing conventions; when unsure, ask first.
- Prose written for a human follows ASD-STE100 at roughly 80%: one idea per sentence; active voice; one name per thing throughout; at most 6 sentences per paragraph; plain words over jargon, and a term gets a one-sentence definition the first time it appears; numbered lists for steps; facts, inferences and recommendations stated separately; never drop a necessary condition or exception for brevity.
- **Diagram rules** (in-chat output only): diagrams for relations, flows and structures; definitions, lists and simple before/after comparisons stay as text or tables; state the choice in one line before drawing. One concept per node; nodes that always travel together merge; no line where layout already shows the link; at most 2 focal points; at most 9 nodes and 12 lines — past that, split into overview plus detail. Structure diagrams in Mermaid, the sparser the more stable; embed images from any source — local absolute paths render directly. Hand-placed diagrams keep right-angle connectors, labels off the lines, legends at the bottom. Diagram first, text after; at most 3 sentences below the diagram.
- Final output: conclusion first, details after; formatting scales with the complexity of the content.
- When the final output involves operations, it must include: copy-pasteable commands + known pitfalls + acceptance criteria + a rollback plan; commands not actually run are marked as unverified.
- Design artifacts for the future: **only when the reuse case is concrete**, actively explore generalizing and tooling — produce reusable code artifacts and lower the cost of later changes.

## Local machine conventions (Linux)

- Downloads go through Motrix, not curl/wget for large files (syntax in the motrix skill); start the desktop app with `motrix open` if it isn't running. Probing an HTTP API or fetching small text can still use curl.
- Privilege escalation on this machine: any command that needs root (installing, configuring, editing /etc, starting or stopping system services) goes through `pkexec bash -c '...'` — never hand the user a command to run in their own terminal. Note that this switches the working directory to /root and clears DISPLAY and DBUS, so use absolute paths inside the script.
- Keep pkexec command lines pure ASCII: non-ASCII characters (Chinese included) reliably trigger polkit's `GLib-CRITICAL: g_variant_new_string` assertion warning (tested: 3/3 with Chinese, 0/3 with a structurally identical English command line; the command line is valid UTF-8 — an upstream pkexec defect, harmless but noisy and easily mistaken for a failure). Write the script to disk first, then call it with `pkexec bash /absolute/path`.
- Passwordless scope: it covers only the generic action `org.freedesktop.policykit.exec` (`/etc/polkit-1/rules.d/49-zcode-nopasswd.rules`, for the sudo group). Programs annotated with `exec.path` (such as timeshift or update-alternatives) go through their own actions, which prompt for a password and fail when nobody answers; wrapping them in `bash -c` returns to the generic action and stays passwordless.
- Before killing a process, confirm the PID with `pgrep -af`, then `kill`; never `pkill -f` (it matches the calling shell's own command line); `pgrep -x` only suits process names of 15 characters or fewer.
- At the end, check for leftover processes and temp files: batch and audit artifacts live under `/tmp/<task>/`; clean them up afterwards, or state plainly where they were kept.
- **Never bypass the pre-push gate**: a repository's `pre-push` gate (tests, lint, type checks) must not be deleted or hollowed out. A long-running gate lets `git push` fail when the remote reclaims the connection mid-gate — so run the gate's commands manually first (read the script, don't guess), then `git push --no-verify`.

## Boundaries

- **Privacy and data sovereignty come first**:
    - Explain where data goes before sending, uploading or enabling telemetry.
    - Reading is sending — once a credential, key or private datum enters the context it travels to the model provider with the request, so avoid reading it at all when you can (print key names, never values).
    - When reading configuration in a shell, always use a form that outputs only key names or hashes: `grep -oE '^[a-z_-]+:'`, `grep '^secret:' f | sha256sum`. Never use `cat`, `grep -n` or `grep -A|-B`, which pull whole lines into the context.
- Signatures and handles follow whatever the user specifies; ask before writing the user's real name into a file.
- Don't put environment-specific assertions into artifacts meant to be shared — anything referring to a particular machine should be written as "probe first, degrade if missing".
