# fable-skill — 肥波模式（Fable Mode）

让 Cursor / Claude Code / Codex 三个编码 agent 共用同一套触发词「**肥波模式**」，激活分阶段执行纪律：

> 阶段地图 → 并行委派（若 runtime 支持）→ 可失败验证 → 交付前自我批判

同时内置三条**任何任务、任何模型都生效**的操作规则（Operational rules）：

1. **Verify before flag**：没有直接证据确认的问题不许上报，"没搜到"不是发现
2. **警告阈值合批**：小问题攒到阈值（默认 3 条）一次性汇报，不逐条打断
3. **查找替换安全**：sed/替换必须锚定词边界（`\bword\b`），替换后 grep 检查粘连词

skill 会按执行模型的档位自动校准强度——前沿模型（Fable/Opus 级）只强制验证纪律，不套完整仪式；Sonnet 级及以下跑完整循环。**触发词激活的是纪律，不是仪式。**

## 目录结构

```
cursor/
  skills/fable-mode/       # 主 skill（含 EXAMPLE.md 四个 worked example）
  skills/fable-sonnet/     # 变体：pin 到 Sonnet 档子 agent 跑
  skills/fable-haiku/      # 变体：pin 到 Haiku 档子 agent 跑
  rules/feibo-fable-mode.mdc   # 全局触发规则（alwaysApply）
claude/
  skills/fable-mode/       # Claude Code 版主 skill（委派段适配 Task 工具 model 参数）
  CLAUDE-snippet.md        # 追加到 ~/.claude/CLAUDE.md 的触发块
codex/
  AGENTS-snippet.md        # 追加到 ~/.codex/AGENTS.md 的触发块
install.sh                 # 幂等安装脚本，支持按目标安装
```

注意：Codex 侧不收录 skill 本体。Codex 用的是第三方插件 [baskduf/FableCodex](https://github.com/baskduf/FableCodex)（AGPL-3.0，含 goal/findings ledger 脚本），本仓库只提供 `AGENTS.md` 触发块并由 `install.sh` 从上游安装该插件。

## 安装（人类）

一键安装（三端全装，缺哪端自动跳过）：

```bash
git clone https://github.com/tanjiancheng/fable-skill.git
cd fable-skill
./install.sh          # 或按需：./install.sh cursor / claude / codex
```

脚本是幂等的，重复运行会用仓库版本覆盖 skill 文件；`CLAUDE.md` / `AGENTS.md` 里只更新 `<!-- fable-skill:start/end -->` 标记块，不动你的其他内容。

### 手动安装

**Cursor**

```bash
cp -r cursor/skills/fable-mode cursor/skills/fable-sonnet cursor/skills/fable-haiku ~/.cursor/skills/
cp cursor/rules/feibo-fable-mode.mdc ~/.cursor/rules/
```

**Claude Code**

```bash
cp -r claude/skills/fable-mode ~/.claude/skills/
cat claude/CLAUDE-snippet.md >> ~/.claude/CLAUDE.md   # 首次安装；已有内容请手动合并
```

**Codex**

```bash
codex plugin marketplace add https://github.com/baskduf/FableCodex.git
codex plugin add codex-fable5@fablecodex
# 然后把 codex/AGENTS-snippet.md 的「## 肥波模式」段追加到 ~/.codex/AGENTS.md
```

## 使用

在任意一端的对话里说出触发词即可：**肥波模式** / **肥波** / **fable mode** / **Fable Mode**（不区分大小写）。

- 大任务（跨多文件/多来源/多会话）：agent 会写出编号的阶段地图，每阶段定义一个"可以失败的检查"，交付前做怀疑式自查
- 小任务：即使触发也不套仪式，只强制验证纪律和三条操作规则
- Cursor 里可点名变体："用 fable-sonnet 跑" / "stage this on haiku"
- Codex 里多阶段任务会启用 goal ledger（`codex-fable5 goals ...`），评审敏感任务会启用 findings ledger

不说触发词时，agent 不会主动套用完整 Fable 仪式。

---

## AI 安装使用说明（给 AI agent 看的）

> 如果你是一个 AI agent，用户让你安装本仓库，请严格按本节执行。本节就是为你写的。

### 你要做什么

把「肥波模式」触发能力装进用户机器上的一个或多个编码 agent 全局配置。共三个目标端，先探测哪些端存在，只装存在的端，装完逐端验证。

### 安装步骤

**第 0 步 — 探测环境**

```bash
ls -d ~/.cursor 2>/dev/null    # 存在 → 需要装 Cursor 端
ls -d ~/.claude 2>/dev/null    # 存在 → 需要装 Claude Code 端
command -v codex               # 存在 → 需要装 Codex 端
```

**第 1 步 — 获取仓库**（若尚未 clone）

```bash
git clone https://github.com/tanjiancheng/fable-skill.git /tmp/fable-skill-install
cd /tmp/fable-skill-install
```

**第 2 步 — 优先跑安装脚本**

```bash
./install.sh
```

脚本幂等、可重复运行，输出 `[ok]` / `[skip]` 汇总。如果脚本运行成功，直接跳到第 4 步验证。只有脚本不可用（如无 bash）时才走第 3 步手动路径。

**第 3 步 — 手动安装（脚本失败时的后备）**

- Cursor：把 `cursor/skills/` 下三个目录整体复制到 `~/.cursor/skills/`，把 `cursor/rules/feibo-fable-mode.mdc` 复制到 `~/.cursor/rules/`。目标已存在时先删旧再复制，不要合并。
- Claude Code：把 `claude/skills/fable-mode/` 整体复制到 `~/.claude/skills/`。然后处理 `~/.claude/CLAUDE.md`：文件不存在则直接写入 `claude/CLAUDE-snippet.md` 内容；已存在则检查是否已有 `<!-- fable-skill:start -->` 标记块，有则替换块内内容，没有则在文件末尾追加（用 `<!-- fable-skill:start -->` 和 `<!-- fable-skill:end -->` 包裹）。**不要覆盖或删除用户 CLAUDE.md 里的其他内容。**
- Codex：先 `codex plugin marketplace add https://github.com/baskduf/FableCodex.git`，再 `codex plugin add codex-fable5@fablecodex`。然后把 `codex/AGENTS-snippet.md` 中「## 肥波模式」标题起的正文（去掉文件头两行注释）按上述同样的标记块规则写入 `~/.codex/AGENTS.md`。

**第 4 步 — 验证（必须执行，逐端确认）**

```bash
# Cursor：三个 skill + 规则文件存在，且 SKILL.md 含 frontmatter
ls ~/.cursor/skills/fable-mode/SKILL.md ~/.cursor/skills/fable-sonnet/SKILL.md \
   ~/.cursor/skills/fable-haiku/SKILL.md ~/.cursor/rules/feibo-fable-mode.mdc
head -3 ~/.cursor/skills/fable-mode/SKILL.md   # 应输出 --- 和 name: fable-mode

# Claude Code：skill 存在 + CLAUDE.md 含触发块
ls ~/.claude/skills/fable-mode/SKILL.md
grep -c "肥波模式" ~/.claude/CLAUDE.md          # 应 >= 1

# Codex：插件已装 + AGENTS.md 含触发块
codex plugin list | grep codex-fable5
grep -c "肥波模式" ~/.codex/AGENTS.md           # 应 >= 1
```

任何一条验证失败，回到对应端重装，不要报告"安装完成"。

### 安装时的注意事项（AI 必读）

1. **不要动用户已有配置的其他部分。** `CLAUDE.md` 和 `AGENTS.md` 是用户的全局记忆文件，只允许操作 `<!-- fable-skill:start/end -->` 标记块。
2. **skill 目录要整体替换而不是合并**，避免旧版残留文件干扰。
3. **Codex 插件装不上不算致命失败**：网络受限时记录 skip 并告知用户手动命令，其余两端照常装。
4. **装完不需要重启**：三端都在会话开始时读取全局配置，新会话即生效；当前会话内让用户说一次「肥波模式」测试即可。
5. 报告结果时按端汇报：装了什么、装到哪、验证命令输出什么、跳过了什么及原因。

### 装完后你（AI）如何使用

用户说「肥波模式 / 肥波 / fable mode」时：读取对应端的 skill（Cursor: `~/.cursor/skills/fable-mode/SKILL.md`；Claude Code: `~/.claude/skills/fable-mode/SKILL.md`；Codex: `codex-fable5` skill），按其中「Calibrate to the model」段位自己的模型档执行——前沿模型只强制可失败验证 + 三条操作规则，Sonnet 级及以下跑完整核心循环。触发词激活的是纪律，不是仪式。

## 来源与许可

- 核心 skill 改编自 [mrtooher/fable-mode](https://github.com/mrtooher/fable-mode)（本仓库版本已内联 execution-guardrails、适配 Cursor Task 工具 slug 与 Claude Code Task 工具 model 参数）
- Codex 端使用 [baskduf/FableCodex](https://github.com/baskduf/FableCodex)（AGPL-3.0-or-later），本仓库不再分发其代码，仅在安装时从上游拉取
