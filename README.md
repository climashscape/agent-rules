# agent-rules

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](LICENSE)

**简体中文** | [English](#english)

写给 AI 编码代理的行为约束，集中在单个 [AGENTS.md](AGENTS.md)（英文版：[AGENTS.en.md](AGENTS.en.md)）。**为 [ZCode](https://zcode.z.ai/) 而写，按 Linux 桌面调校。**

一句话原则：**每条规则都是真约束，宁缺毋滥；验证与询问的强度与影响面成正比。**

## 哪些部分是平台特定的

其余内容与代理、操作系统无关，只有这两处例外：

- **ZCode**——原则 1 围绕 ZCode 的提问工具（`AskUserQuestion`）写成，包含「写在 ASK 之前的正文会被折叠、等于没交付」这个坑。换一个提问机制不同的代理，这条需要重写。
- **Linux 桌面**——`本机操作约定（Linux）` 整节：走 Motrix 下载、用 `pkexec` 提权、批处理产物放 `/tmp/<task>/`，以及更安全的杀进程约定。macOS 或 Windows 上请删除或重写。

## 内容

四节，七条协作原则。

**协作原则**

1. **决策分层与待决先问**——涉及架构、成本、数据安全、不可逆操作、与既有偏好相悖，或出现「下一步取决于用户选择」的分支时，先用提问工具拍板，拿到答复再输出最终内容。
2. **输入纪律**——对外的事实断言先取证，改动本机状态前先扫描，外来输入先核实再落实。
3. **审计与修改分离**——审查类任务先交只读报告，获授权再动手。
4. **偏好操作而非建议**——环境搭建、系统配置、批量任务直接执行并交付；默认动作是执行而非请示。
5. **最小化与复用**——工具按需安装且每件能说出用途；写新东西前先查既有资产与现成方案。
6. **同一问题同类失败 ≥3 次就换方案**——不做第四次微修；换方案前先报告已试过的失败路径。
7. **故障处置**——出故障就停手，如实报告现状、影响面与回滚路径；能安全回滚的先回滚。

**工作偏好**：语言与文风约定、仅在复用场景明确时才做通用化、最终输出先结论后细节，以及涉及操作时的交付标准（可复制命令 + 已知坑 + 验收标准 + 回滚预案），未经实跑的命令明确标注。

**本机操作约定（Linux）**：Motrix 下载、`/tmp/<task>/` 暂存、安全的杀进程约定、`pkexec` 提权及其免密范围。

**边界**：隐私与数据主权（含「读入即外发」——凭据一进上下文就随请求发往模型提供方，故只打印键名或哈希、不打印值）、署名约定、不把环境相关的断言写进要分享的产物。

## 用法

1. 把 `AGENTS.md` 复制成你的全局指令文件（如 `~/.zcode/AGENTS.md` 或 `~/.claude/CLAUDE.md`），或放进某个项目根目录——项目级优先。
2. 「本机操作约定」与「边界」两节含作者本机的条目（提权方式、临时路径、Motrix）。移植时替换成你自己的实况；涉及具体机器的表述写成「先探测、缺失时降级」。
3. 规则贵精不贵多——留不下的规则只会稀释真正重要的那些。

## 配套工具

规则正文依赖下面这些东西。前两项是公开项目，链接直接给官方来源；第三项是 Linux 提权，脚本随本仓库一起提供。

- **ZCode**——规则就是为它写的，原则 1 依赖它的提问工具。官网 <https://zcode.z.ai/>，源码 <https://github.com/zai-org/ZCode>。
- **Motrix**——「下载统一走 Motrix」那节的工具本体，一个跨平台下载器。官网 <https://motrix.app/>，源码 <https://github.com/agalwood/Motrix>。规则里提到的「motrix skill」是作者本机的技能文件，**没有随本仓库发布**；读者可以自己写一份，或直接查 Motrix 自己的接口说明。
- **polkit 免密提权**——`pkexec` 默认每次都弹密码，无人值守的脚本会卡死在那里。本仓库带一个脚本，把 polkit 的**通用 action** 授权给指定组，让 `pkexec bash -c '...'` 免密可用：[`companion/polkit-nopasswd.sh`](companion/polkit-nopasswd.sh)。先用 `--dry-run` 看它打算写什么，`--uninstall` 撤回。polkit 自身文档见 <https://polkit.pages.freedesktop.org/polkit/>。

⚠️ 那个 pkexec 脚本等于让指定组的成员**免密拿到 root**。这正是它的用途，也正是它的风险——只在确实需要无人值守 root 的机器上用，并且把那个组保持得尽量小。

## 相关

同一问题上的其它做法，可供对比：

- [agentsmd/agents.md](https://github.com/agentsmd/agents.md)——本文件遵循的 AGENTS.md 开放格式。
- [steipete/agent-rules](https://github.com/steipete/agent-rules)——一个体量大得多的个人规则集。
- [ciembor/agent-rules-books](https://github.com/ciembor/agent-rules-books)——从经典工程书里提炼出的规则。

## 许可

© 2026 climashscape，采用 [CC BY 4.0](LICENSE) 许可——自由使用、修改与再分发，保留署名即可。

---

## English

My coding-agent collaboration rules, kept in a single [AGENTS.md](AGENTS.md) (English version: [AGENTS.en.md](AGENTS.en.md)) — behavioral constraints for AI coding agents, **written for [ZCode](https://zcode.z.ai/) and tuned to a Linux desktop**.

The idea in one line: **every rule is a real constraint, so keep them few — verification and questions scale with the blast radius of the action.**

### What is platform-specific

Everything else is agent- and OS-agnostic; these two parts are not:

- **ZCode** — principle 1 is built around ZCode's asking tool (`AskUserQuestion`), including the trap that text written before the question gets collapsed and never read. Retarget it if your agent asks differently.
- **Linux desktop** — the `本机操作约定（Linux）` section: downloads through Motrix, `pkexec` for root commands, batch artifacts under `/tmp/<task>/`, and a safer process-killing convention. Drop or rewrite it on macOS or Windows.

### Contents

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

### Usage

1. Copy `AGENTS.md` to your global instruction file (e.g. `~/.zcode/AGENTS.md` or `~/.claude/CLAUDE.md`), or into a project root — project-level rules win.
2. The local-machine and boundary sections carry author-specific items (privilege escalation, temp paths, Motrix). Replace them with your own reality; where a statement is machine-specific, write it as "probe first, degrade if missing".
3. Rules you won't enforce dilute the ones you will. Cut them.

### Companion tools

The rules lean on these. The first two are public projects — links go to the official sources; the third is a Linux privilege-escalation setup, and the script ships with this repository.

- **ZCode** — the agent these rules were written for; principle 1 relies on its asking tool. Site <https://zcode.z.ai/>, source <https://github.com/zai-org/ZCode>.
- **Motrix** — the cross-platform download manager behind the "downloads go through Motrix" convention. Site <https://motrix.app/>, source <https://github.com/agalwood/Motrix>. The "motrix skill" the rules mention is an author-local skill file and **is not published here**; write your own, or read Motrix's own interface directly.
- **Passwordless pkexec** — `pkexec` asks for a password every time, which stalls unattended scripts. This repository ships a script that grants polkit's **generic action** to a group, so `pkexec bash -c '...'` works unattended: [`companion/polkit-nopasswd.sh`](companion/polkit-nopasswd.sh). Run it with `--dry-run` first to see what it would write, and `--uninstall` to revoke. Polkit's own documentation: <https://polkit.pages.freedesktop.org/polkit/>.

⚠️ The pkexec script gives every member of the chosen group passwordless root. That is the point, and the risk — use it only where unattended root is genuinely required, and keep that group small.

### Related

Other takes on the same problem, if you want something different:

- [agentsmd/agents.md](https://github.com/agentsmd/agents.md) — the open AGENTS.md format this file follows.
- [steipete/agent-rules](https://github.com/steipete/agent-rules) — a much larger personal ruleset.
- [ciembor/agent-rules-books](https://github.com/ciembor/agent-rules-books) — rules distilled from classic engineering books.

### License

© 2026 climashscape. Licensed under [CC BY 4.0](LICENSE) — reuse, modify and redistribute freely; keep the attribution.
