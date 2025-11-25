# 代码审查报告 (Code Review Report)

经过对 `PomodoroTimer` 项目的审查，以下是关于设计模式、逻辑、性能及稳定性方面的发现和改进建议。

## 1. 逻辑问题 (Logical Issues)

### 🔴 严重：热力图 (Heatmap) 日期对齐错误
- **问题描述**: 在 `HeatmapView.swift` 中，网格日期的计算逻辑是 `daysAgo = weeksAgo * 7 + day`，然后用 `today - daysAgo`。这意味着网格的第一行 (`day=0`) 永远代表“今天”、“一周前的今天”、“两周前的今天”等。
- **后果**: 热力图的行标签（一、三、五）是固定的（代表周一、周三、周五），但网格内容却是相对于“今天”滚动的。除非今天恰好是周一，否则行标签与实际数据显示的日期不仅不对应，而且每天都在错位。
- **建议**: 重构热力图日期计算逻辑。网格的行应当代表固定的星期几（如 0=周日, 1=周一...）。需要根据今天所在的星期几，反推网格起始日期的偏移量。

### 🟠 中等：计时器实现方式不精准
- **问题描述**: `PomodoroManager` 使用 `Timer` 每秒触发并执行 `timeRemaining -= 1`。
- **后果**: `Timer` 在系统负载高或应用处于后台/睡眠时可能会发生漂移或暂停。直接递减计数器会导致计时不准确（通常会比实际时间慢）。
- **建议**: 记录计时开始的时间戳 `endTime = Date() + duration`，每次 tick 时计算 `remaining = endTime - Date()`。

### 🟠 中等：数据竞争风险
- **问题描述**: `loadSessions` 在后台线程加载数据，然后分发到主线程更新。但在加载过程中，如果用户触发了 `saveSessions`（虽然不太可能在启动瞬间完成番茄钟，但理论上存在），可能会导致数据覆盖或状态不一致。
- **建议**: 确保数据访问的线程安全性，或者在数据加载完成前禁用相关操作。

## 2. 性能与稳定性问题 (Performance & Stability)

### 🔴 严重：主线程文件 I/O
- **问题描述**: `PomodoroManager.saveSessions` 调用 `storage.save`，后者使用 `Data.write` 进行文件写入。该调用链是在主线程（Timer tick -> completeSession -> saveSessions）中执行的。
- **后果**: 随着历史记录文件 `pomodoro_sessions.json` 变大，写入操作会导致主线程阻塞，引起 UI 卡顿（掉帧）。
- **建议**: 将文件写入操作放入后台队列（如 `DispatchQueue.global(qos: .background)`）执行。

### 🟠 中等：热力图渲染性能 (O(N) vs O(1))
- **问题描述**: `HeatmapView` 中的 `sessionCount(for:day:)` 方法会为网格中的每一个单元格（约 84 次）遍历整个 `sessions` 数组。
- **后果**: 随着 `sessions` 数据量增长，渲染热力图的复杂度为 `O(Cells * Sessions)`。如果有几千条记录，会导致显著的 UI 延迟。
- **建议**: 在数据加载或更新时，预先计算一个 `[DateKey: Int]` 的字典。热力图渲染时直接通过字典进行 O(1) 查找。

### 🟢 轻微：应用状态丢失
- **问题描述**: 应用没有持久化“当前正在进行的番茄钟”的状态。
- **后果**: 如果应用意外退出或崩溃，重启后当前的计时进度会丢失，重置为默认时长。
- **建议**: 在 `UserDefaults` 中存储当前计时器的 `startTime` 和 `duration`，启动时恢复现场。

## 3. 设计模式与代码结构 (Design Patterns & Architecture)

### 🟡 改进点：View 中的业务逻辑
- **问题描述**: `HeatmapView` 包含大量关于日期的业务逻辑计算。
- **建议**: 将这些逻辑提取到 `PomodoroManager` 或专门的 ViewModel 中，View 只负责展示。

### 🟡 改进点：硬编码常量
- **问题描述**: 番茄钟时长（25分钟）、休息时长（5分钟）在 `PomodoroManager` 中硬编码。
- **建议**: 提取为配置常量或允许用户设置。

### 🟡 改进点：依赖注入的使用
- **观察**: 代码使用了 `StorageProtocol` 和 `NotificationServiceProtocol`，这是很好的设计，便于单元测试。
