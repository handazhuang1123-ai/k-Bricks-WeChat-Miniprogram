# ToT (Tree of Thoughts) Problem Solver

You are about to invoke the **Tree of Thoughts** system—a powerful multi-agent framework for solving complex problems through systematic exploration of reasoning paths.

---

## What is ToT?

ToT transforms problem-solving into **tree search**:
- Each **node** = a partial solution (intermediate reasoning state)
- Each **edge** = a reasoning step
- **Search** explores multiple paths simultaneously
- **Evaluation** identifies promising branches
- **Backtracking** abandons dead ends

Based on: [Tree of Thoughts: Deliberate Problem Solving with Large Language Models](https://arxiv.org/html/2305.10601v2)

---

## When to Use ToT

**✅ Ideal for**:
- **Complex reasoning**: Math puzzles, logic problems (Game of 24)
- **Creative tasks**: Writing with constraints, design brainstorming
- **Planning**: Multi-step projects, scheduling, resource allocation
- **Architecture decisions**: Comparing technical solutions with trade-offs
- **Debugging**: Hypothesis-driven root cause analysis

**❌ Not suitable for**:
- Simple factual queries ("什么是...?")
- Single-step operations
- Highly time-sensitive tasks (ToT uses multiple LLM calls)

---

## How It Works

```
Your Problem
    ↓
┌────────────────────────────────────┐
│  1. Orchestrator                   │  ← Analyzes problem, selects strategy
├────────────────────────────────────┤
│  2. Decomposer                     │  ← Breaks down into thought steps
├────────────────────────────────────┤
│  3. Explorer                       │  ← Manages search tree
│     ├─ Generator (creates options) │
│     └─ Evaluator (scores options)  │
├────────────────────────────────────┤
│  4. Synthesizer                    │  ← Generates final answer
└────────────────────────────────────┘
    ↓
Complete Solution + Reasoning Trace
```

---

## Usage

Simply state your problem after the command:

```
/tot 用 4、9、10、13 得到 24

/tot 写一个段落，必须以"她笑了。雨停了。门开了。他走了。"结尾

/tot 小程序应该用什么状态管理方案？需要支持全局状态和性能优化

/tot 设计一个7周的项目上线计划，包括需求、开发、测试、发布
```

---

## What to Expect

ToT will:
1. **Analyze** your problem and choose the appropriate search strategy
2. **Explore** multiple reasoning paths (you'll see progress updates)
3. **Evaluate** each path's promise
4. **Return** the best solution with complete reasoning trace
5. **Show statistics** (nodes explored, search depth, etc.)

**Note**: ToT may take longer than a direct answer (due to exploration), but provides **higher quality solutions** for complex problems.

---

## Examples

### Example 1: Math Reasoning
**Input**: `/tot 用 4、9、10、13 得到 24`

**Output**:
```
最终答案: (10 - (13 - 9)) × 4 = 24

推理过程:
1. 步骤1: 计算 13 - 9 = 4
2. 步骤2: 计算 10 - 4 = 6
3. 步骤3: 计算 6 × 4 = 24 ✓

搜索统计:
- 探索节点数: 18
- 搜索深度: 3
- 策略: BFS (广度优先)
```

### Example 2: Architecture Design
**Input**: `/tot 小程序用什么状态管理？需要全局共享+性能优化`

**Output**:
```
推荐: MobX

理由:
- 响应式状态管理，性能优于手动 setData
- 学习成本低，团队可快速上手
- Bundle size 30KB，符合小程序限制
- 适合中小型项目

Trade-offs:
- 优点: 开发效率高、代码少、性能好
- 缺点: 生态不如 Redux 成熟

替代方案:
- Redux: 如果团队已有经验且项目规模大
- 原生 globalData: 如果状态逻辑极简单
```

---

## Architecture

ToT uses **6 specialized subagents**:

1. **tot-orchestrator**: Coordinates the entire workflow
2. **tot-decomposer**: Defines thought granularity (what is one "step"?)
3. **tot-generator**: Creates candidate next steps (3-5 options)
4. **tot-evaluator**: Scores each candidate (0-10 scale)
5. **tot-explorer**: Executes search (BFS or DFS), manages tree
6. **tot-synthesizer**: Extracts final answer from best path

Each agent is autonomous and communicates via structured messages (see `.claude/tot-docs/protocol.md`).

---

## Configuration (Advanced)

ToT automatically selects parameters based on task type. Defaults:

| Task Type | Strategy | Branching Factor | Max Depth | Pruning Threshold |
|-----------|----------|------------------|-----------|-------------------|
| Math | BFS | 5 | 3-4 | 5.0 |
| Creative | BFS | 3-4 | 2-3 | 6.0 |
| Planning | DFS | 3 | 3-5 | 5.5 |
| Architecture | BFS | 3-4 | 2-3 | 6.5 |

If you want to override (rarely needed):
```
/tot [problem] --strategy=DFS --depth=5 --branching=3
```

---

## Debugging

If ToT produces unexpected results:
1. Check `.claude/tot-docs/architecture.md` for design rationale
2. Review search tree snapshot (saved to `.claude/tot-docs/tree-snapshot-*.json`)
3. Verify protocol compliance in `.claude/tot-docs/protocol.md`

---

## Current Task

**Your Problem**: {{USER_INPUT}}

Invoking **tot-orchestrator** to begin Tree of Thoughts exploration...

---
