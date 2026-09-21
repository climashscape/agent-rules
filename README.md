# agent-rules

My coding-agent collaboration rules, kept in a single [AGENTS.md](AGENTS.md) — behavioral constraints for AI coding agents (ZCode / Claude Code / Copilot Workspace, …), placed at the agent's instruction entry point so they apply to every session.

The idea in one line: **every rule is a real constraint, so keep them few — verification and questions scale with the blast radius of the action.**

## Contents

Four sections, seven collaboration principles.

**协作原则 — Collaboration principles**

1. **Decision tiers, ask first** — architecture, cost, data safety, irreversible actions, or any branch whose next step depends on the user: ask before delivering, not after.
2. **Input discipline** — search before asserting outside facts, scan before touching machine state, verify third-party input instead of accepting it wholesale.
3. **Audit and modification are separate** — reviews land as read-only reports; act only once authorized.
4. **Act, don't advise** — set up the environment, run the batch, deliver the result. Asking is for decisions, not for permission to work.
5. **Minimize and reuse** — install tools on demand and be able to justify each one; check existing assets before writing anything new.
6. **Three same-class failures → change the approach** — not a fourth micro-fix; report the failed paths first.
7. **Incident handling** — stop, report state / blast radius / rollback path honestly, roll back when that is safe.

**工作偏好 — Work preferences**: language conventions (Chinese dialogue, English for outward-facing artifacts), design for reuse only when the reuse case is concrete, conclusion-first output, and a delivery checklist for anything actionable — copy-pasteable commands, known pitfalls, acceptance criteria, rollback plan — with unverified commands marked as such.

**本机操作约定（Linux）— Local machine conventions**: downloads through Motrix rather than curl/wget, batch and audit artifacts under `/tmp/<task>/`, safe process killing, and root commands through `pkexec` instead of handing the user terminal commands.

**边界 — Boundaries**: privacy and data sovereignty — including "reading is sending": anything read into context travels to the model provider, so print key names or hashes, never values — plus attribution, and no environment-specific claims in shareable artifacts.

## Usage

1. Copy `AGENTS.md` to your global instruction file (e.g. `~/.zcode/AGENTS.md`), or into a project root — project-level rules win.
2. The local-machine and boundary sections carry author-specific items (privilege escalation, temp paths, Motrix). Replace them with your own reality; where a statement is machine-specific, write it as "probe first, degrade if missing".
3. Rules you won't enforce dilute the ones you will. Cut them.

## License

© 2026 climashscape. Licensed under [CC BY 4.0](LICENSE) — reuse, modify and redistribute freely; keep the attribution.
