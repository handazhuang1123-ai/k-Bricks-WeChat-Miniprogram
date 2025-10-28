# ToT (Tree of Thoughts) 通信协议

本文档定义 ToT 系统中各 Agent 间的消息格式和数据结构规范。

---

## 核心数据结构

### ThoughtNode（思维节点）

```json
{
  "id": "string",              // 唯一标识，如 "node_1_2"
  "parent_id": "string|null",  // 父节点ID，根节点为 null
  "children_ids": ["string"],  // 子节点ID列表
  "depth": "number",           // 深度（根节点为0）

  "content": "string",         // 思维内容
  "action_type": "string",     // 操作类型（如 "equation", "hypothesis"）

  "evaluation": {
    "score": "number",         // 0-10 评分
    "confidence": "number",    // 0-1 置信度
    "reasoning": "string"      // 评分理由
  } | null,

  "status": "pending|expanded|pruned|terminal",
  "metadata": {}               // 任务特定信息
}
```

### ThoughtTree（思维树）

```json
{
  "task_id": "string",
  "problem": "string",
  "task_type": "string",       // "math_reasoning" | "creative_writing" | "planning"

  "search_config": {
    "strategy": "BFS|DFS",
    "max_depth": "number",
    "branching_factor": "number",
    "pruning_threshold": "number"
  },

  "nodes": {                   // 节点索引 {id: ThoughtNode}
    "root": {...},
    "node_1": {...}
  },
  "root_id": "string",

  "search_state": {
    "current_depth": "number",
    "frontier": ["string"],    // 待扩展节点队列
    "best_path": ["string"]    // 当前最佳路径
  }
}
```

---

## Agent 消息格式

### 基础消息结构

```json
{
  "from": "orchestrator|decomposer|generator|evaluator|explorer|synthesizer",
  "to": "string",
  "type": "string",
  "payload": {},
  "task_id": "string"
}
```

---

## 1. Orchestrator ↔ Decomposer

### 请求：decompose_task

```json
{
  "type": "decompose_task",
  "payload": {
    "problem": "string",
    "task_type": "string"
  }
}
```

### 响应：decomposition_result

```json
{
  "type": "decomposition_result",
  "payload": {
    "thought_granularity": "string",      // "equation" | "paragraph" | "hypothesis"
    "intermediate_steps": ["string"],     // 步骤描述
    "depth_estimate": "number",           // 预估树深度
    "constraints": ["string"],            // 任务约束
    "success_criteria": "string"          // 成功标准
  }
}
```

**示例**：
```json
{
  "thought_granularity": "single_equation",
  "intermediate_steps": [
    "Step 1: 选择两个数字进行运算",
    "Step 2: 用结果与第三个数字运算",
    "Step 3: 得到目标数字24"
  ],
  "depth_estimate": 3,
  "constraints": ["必须使用所有数字各一次", "只能用+-×÷"],
  "success_criteria": "最终结果等于24"
}
```

---

## 2. Explorer ↔ Generator

### 请求：generate_thoughts

```json
{
  "type": "generate_thoughts",
  "payload": {
    "parent_node": "ThoughtNode",
    "generation_strategy": "independent_sampling|sequential_proposal",
    "num_candidates": "number",
    "context": {
      "problem": "string",
      "goal": "string",
      "constraints": ["string"]
    }
  }
}
```

### 响应：generated_thoughts

```json
{
  "type": "generated_thoughts",
  "payload": {
    "candidates": [
      {
        "temp_id": "string",           // 临时ID（由Explorer分配正式ID）
        "content": "string",
        "action_type": "string",
        "metadata": {}
      }
    ]
  }
}
```

**示例（游戏24）**：
```json
{
  "candidates": [
    {
      "temp_id": "cand_1",
      "content": "13 - 9 = 4, 剩余: 4, 4, 10",
      "action_type": "subtraction"
    },
    {
      "temp_id": "cand_2",
      "content": "10 + 4 = 14, 剩余: 9, 13, 14",
      "action_type": "addition"
    }
  ]
}
```

---

## 3. Explorer ↔ Evaluator

### 请求：evaluate_thoughts

```json
{
  "type": "evaluate_thoughts",
  "payload": {
    "candidates": ["ThoughtNode"],
    "evaluation_strategy": "independent_scoring|comparative_voting",
    "evaluation_criteria": ["string"],
    "context": {
      "problem": "string",
      "goal": "string",
      "current_depth": "number",
      "max_depth": "number"
    }
  }
}
```

### 响应：evaluation_results

```json
{
  "type": "evaluation_results",
  "payload": {
    "evaluations": [
      {
        "node_id": "string",
        "score": "number",           // 0-10
        "confidence": "number",      // 0-1
        "reasoning": "string",
        "dimension_scores": {        // 各维度分数
          "correctness": "number",
          "progress": "number",
          "feasibility": "number"
        }
      }
    ],
    "ranking": ["string"],           // 按分数排序的 node_id
    "pruning_suggestions": ["string"] // 建议剪枝的 node_id
  }
}
```

**示例**：
```json
{
  "evaluations": [
    {
      "node_id": "node_1_1",
      "score": 7.5,
      "confidence": 0.8,
      "reasoning": "产生了4的倍数，剩余数字可组合成24",
      "dimension_scores": {
        "correctness": 10,
        "progress": 5
      }
    }
  ],
  "ranking": ["node_1_1", "node_1_2"],
  "pruning_suggestions": []
}
```

---

## 4. Orchestrator ↔ Explorer

### 请求：initialize_search

```json
{
  "type": "initialize_search",
  "payload": {
    "problem": "string",
    "task_type": "string",
    "search_config": {
      "strategy": "BFS|DFS",
      "max_depth": "number",
      "branching_factor": "number",
      "pruning_threshold": "number"
    },
    "decomposition_result": {}   // 来自 Decomposer 的结果
  }
}
```

### 响应：search_complete

```json
{
  "type": "search_complete",
  "payload": {
    "best_path": ["ThoughtNode"],   // 从 root 到最佳终端节点
    "tree": "ThoughtTree",          // 完整树结构
    "stats": {
      "total_nodes": "number",
      "total_backtracks": "number",
      "llm_calls": "number"
    }
  }
}
```

---

## 5. Explorer ↔ Synthesizer

### 请求：synthesize_solution

```json
{
  "type": "synthesize_solution",
  "payload": {
    "best_path": ["ThoughtNode"],
    "problem": "string",
    "task_type": "string"
  }
}
```

### 响应：final_solution

```json
{
  "type": "final_solution",
  "payload": {
    "answer": "string",
    "reasoning_trace": ["string"],   // 推理步骤
    "confidence": "number",          // 0-1
    "verification": {
      "is_valid": "boolean",
      "validation_errors": ["string"]
    },
    "alternative_solutions": ["string"]
  }
}
```

**示例（游戏24）**：
```json
{
  "answer": "(10 - (13 - 9)) × 4 = 24",
  "reasoning_trace": [
    "步骤1: 用13减9得到4",
    "步骤2: 用10减去上一步的4得到6",
    "步骤3: 用6乘以剩余的4得到24"
  ],
  "confidence": 1.0,
  "verification": {
    "is_valid": true
  }
}
```

---

## 生成策略说明

### Independent Sampling（独立采样）
- 适用场景：开放性任务（创意写作、头脑风暴）
- 方法：为每个候选独立调用 LLM
- 优点：候选多样性高
- 成本：k 次 LLM 调用

### Sequential Proposal（序列提议）
- 适用场景：约束性任务（数学推理、逻辑推理）
- 方法：单次 LLM 调用生成多个候选
- 优点：成本低，候选间有对比关系
- 成本：1 次 LLM 调用

---

## 评估策略说明

### Independent Scoring（独立评分）
- 适用场景：需要细粒度评分（0-10分）
- 方法：为每个候选独立评分
- 成本：n 次 LLM 调用

### Comparative Voting（对比投票）
- 适用场景：只需选出 top-k
- 方法：多个候选一起比较
- 成本：1 次 LLM 调用

---

## 搜索策略说明

### BFS（广度优先搜索）
- 适用场景：浅层任务（depth ≤ 3）
- 特点：每层保留 b 个最佳节点
- 保证：找到全局较优解

### DFS（深度优先搜索）
- 适用场景：深层任务、需要快速探索
- 特点：探索单条路径到底，不行就回溯
- 优点：内存占用低

---

## 任务类型映射

| 任务类型 | 思维粒度 | 推荐深度 | 推荐策略 | 评估方法 |
|---------|---------|---------|---------|---------|
| **math_reasoning** | equation | 3-4 | BFS | Independent Scoring |
| **creative_writing** | paragraph | 2-3 | BFS | Comparative Voting |
| **planning** | action_step | 3-5 | DFS | Independent Scoring |
| **debugging** | hypothesis | 不定 | DFS | Independent Scoring |
| **architecture_design** | component | 2-3 | BFS | Comparative Voting |

---

## 使用示例

### 完整流程（游戏24）

```
1. Orchestrator → Decomposer
   问题: "用4、9、10、13得到24"

2. Decomposer → Orchestrator
   返回: depth=3, granularity="equation"

3. Orchestrator → Explorer
   初始化: BFS, branching_factor=5

4. Explorer → Generator
   生成5个候选运算

5. Generator → Explorer
   返回: [候选1, 候选2, ...]

6. Explorer → Evaluator
   评估这5个候选

7. Evaluator → Explorer
   返回: [评分1, 评分2, ...]

8. Explorer 内部
   选择 top-3 进入下一层

9. 重复步骤 4-8 直到 depth=3

10. Explorer → Synthesizer
    传递最佳路径

11. Synthesizer → Explorer → Orchestrator
    返回最终答案
```

---

## 错误处理

所有消息可能包含 `error` 字段：

```json
{
  "error": {
    "code": "string",
    "message": "string",
    "recoverable": "boolean"
  }
}
```

常见错误码：
- `INVALID_FORMAT`: 消息格式不符合协议
- `GENERATION_FAILED`: 生成候选失败
- `EVALUATION_TIMEOUT`: 评估超时
- `SEARCH_EXHAUSTED`: 搜索空间耗尽

---

**协议版本**: 1.0
**最后更新**: 2025-10-28
