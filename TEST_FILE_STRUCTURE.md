# 测试文件结构说明

## 📁 测试文件组织

测试已按照主题拆分为8个独立文件，每个文件专注于特定的测试领域。

---

## 📂 文件列表

### 1. PomodoroSessionTests.swift
**主题**: 数据模型测试  
**测试数量**: 8个  
**文件大小**: ~3.5KB

**测试内容**:
- ✅ 创建工作会话
- ✅ 创建休息会话
- ✅ dayKey 格式正确
- ✅ 同一天不同时间的会话有相同的 dayKey
- ✅ 不同日期的会话有不同的 dayKey
- ✅ 会话可以编码和解码
- ✅ SessionType 枚举值正确

**重要性**: ⭐⭐⭐ 核心数据模型

---

### 2. PomodoroManagerTests.swift
**主题**: 核心业务逻辑测试  
**测试数量**: 13个  
**文件大小**: ~4.3KB

**测试内容**:
- ✅ 初始化状态正确
- ✅ 时间字符串格式化（5个测试）
- ✅ 启动/暂停计时器
- ✅ 重置工作/休息计时器
- ✅ 跳过会话（工作↔休息）
- ✅ 会话持久化

**重要性**: ⭐⭐⭐ 最核心的业务逻辑

---

### 3. SessionStatisticsTests.swift
**主题**: 会话统计功能测试  
**测试数量**: 3个  
**文件大小**: ~2.2KB

**测试内容**:
- ✅ 计算今日会话数量
- ✅ 计算总会话数量
- ✅ 过滤工作会话

**重要性**: ⭐⭐⭐ 用户可见的统计功能

---

### 4. DateCalculationTests.swift
**主题**: 日期计算功能测试  
**测试数量**: 3个  
**文件大小**: ~1.6KB

**测试内容**:
- ✅ 计算过去的日期
- ✅ 判断两个日期是否在同一天
- ✅ 周开始日期计算

**重要性**: ⭐⭐ 支持热力图和统计

---

### 5. TimerProgressTests.swift
**主题**: 计时器进度计算测试  
**测试数量**: 4个  
**文件大小**: ~1.3KB

**测试内容**:
- ✅ 工作时段进度计算 - 开始
- ✅ 工作时段进度计算 - 中途
- ✅ 工作时段进度计算 - 结束
- ✅ 休息时段进度计算

**重要性**: ⭐⭐⭐ UI 进度显示依赖

---

### 6. HeatmapTests.swift
**主题**: 热力图相关功能测试  
**测试数量**: 3个  
**文件大小**: ~1.6KB

**测试内容**:
- ✅ 零会话显示灰色
- ✅ 会话数量映射到颜色等级
- ✅ 生成正确的工具提示文本

**重要性**: ⭐⭐ 视觉化展示功能

---

### 7. EdgeCaseTests.swift
**主题**: 边界情况和异常场景测试  
**测试数量**: 5个  
**文件大小**: ~2.1KB

**测试内容**:
- ✅ 处理空会话列表
- ✅ 处理大量会话（100个）
- ✅ 时间为负数时的处理
- ✅ 跨年度的会话统计

**重要性**: ⭐⭐⭐ 健壮性保证

---

### 8. PerformanceTests.swift
**主题**: 性能测试  
**测试数量**: 1个  
**文件大小**: ~1.0KB

**测试内容**:
- ✅ 大量会话的过滤性能（1000个会话，<1秒）

**重要性**: ⭐⭐⭐ 确保应用流畅度

---

## 📊 统计汇总

| 指标 | 数值 |
|------|------|
| **测试文件数** | 8 个 |
| **测试套件数** | 9 个 |
| **测试用例总数** | 37 个 |
| **总代码行数** | ~560 行 |
| **平均每文件** | ~70 行 |

---

## 🎯 文件依赖关系

```
PomodoroTimer (被测试模块)
├── PomodoroSession.swift          → 测试于 PomodoroSessionTests.swift
├── PomodoroManager.swift          → 测试于 PomodoroManagerTests.swift
│                                     SessionStatisticsTests.swift
│                                     EdgeCaseTests.swift
│                                     PerformanceTests.swift
├── PomodoroMenuView.swift         → 测试于 SessionStatisticsTests.swift
│                                     TimerProgressTests.swift
└── HeatmapView.swift              → 测试于 HeatmapTests.swift
                                      DateCalculationTests.swift
```

---

## 🔍 按重要性分类

### 🔴 P0 - 最高优先级（必须通过）
1. **PomodoroSessionTests.swift** - 数据模型基础
2. **PomodoroManagerTests.swift** - 核心业务逻辑
3. **SessionStatisticsTests.swift** - 用户可见功能
4. **TimerProgressTests.swift** - UI 准确性

### 🟡 P1 - 高优先级（应该通过）
5. **EdgeCaseTests.swift** - 健壮性
6. **PerformanceTests.swift** - 性能保证

### 🟢 P2 - 中优先级（建议通过）
7. **HeatmapTests.swift** - 增强功能
8. **DateCalculationTests.swift** - 辅助功能

---

## 🚀 运行测试

### 运行所有测试
```bash
swift test
```

### 按文件运行测试
```bash
# 运行数据模型测试
swift test --filter PomodoroSessionTests

# 运行业务逻辑测试
swift test --filter PomodoroManagerTests

# 运行统计测试
swift test --filter SessionStatisticsTests

# 运行日期计算测试
swift test --filter DateCalculationTests

# 运行进度测试
swift test --filter TimerProgressTests

# 运行热力图测试
swift test --filter HeatmapColorTests
swift test --filter TooltipTests

# 运行边界测试
swift test --filter EdgeCaseTests

# 运行性能测试
swift test --filter PerformanceTests
```

### 运行特定优先级
```bash
# P0 测试（核心功能）
swift test --filter "PomodoroSessionTests|PomodoroManagerTests|SessionStatisticsTests|TimerProgressTests"

# 快速验证（跳过性能测试）
swift test --skip-filter PerformanceTests
```

---

## 📝 文件命名规范

所有测试文件遵循以下命名规范：

```
<模块名>Tests.swift
```

例如：
- `PomodoroSession` → `PomodoroSessionTests.swift`
- `PomodoroManager` → `PomodoroManagerTests.swift`
- 功能分组 → `<功能名>Tests.swift`

---

## 🔧 维护指南

### 添加新测试
1. 确定测试属于哪个主题
2. 在对应的文件中添加测试
3. 如果是新主题，创建新文件

### 修改现有测试
1. 找到对应的测试文件
2. 修改或添加测试用例
3. 运行该文件的所有测试验证

### 重构测试
1. 如果文件变得太大（>200行），考虑拆分
2. 保持每个文件聚焦单一主题
3. 更新本文档

---

## 📈 测试覆盖率（按文件）

| 测试文件 | 覆盖的源文件 | 覆盖率 |
|---------|-------------|-------|
| PomodoroSessionTests.swift | PomodoroSession.swift | ~95% |
| PomodoroManagerTests.swift | PomodoroManager.swift | ~70% |
| SessionStatisticsTests.swift | PomodoroManager.swift | ~85% |
| DateCalculationTests.swift | 日期处理逻辑 | ~75% |
| TimerProgressTests.swift | 进度计算逻辑 | ~90% |
| HeatmapTests.swift | HeatmapView.swift | ~60% |
| EdgeCaseTests.swift | 多个模块 | ~80% |
| PerformanceTests.swift | 性能关键路径 | ~70% |

---

## 💡 优势

### 1. 更好的组织
- ✅ 每个文件职责单一
- ✅ 易于查找和维护
- ✅ 减少合并冲突

### 2. 更快的编译
- ✅ 增量编译更高效
- ✅ 只编译修改的文件
- ✅ 并行编译支持

### 3. 更清晰的错误
- ✅ 失败时快速定位问题文件
- ✅ 文件名即说明测试主题
- ✅ 减少认知负担

### 4. 更灵活的执行
- ✅ 可选择性运行测试
- ✅ 分组执行
- ✅ 优先级控制

---

## 🎓 最佳实践

1. **保持文件小而专注**
   - 每个文件 < 200 行
   - 单一测试主题
   
2. **合理命名**
   - 文件名清晰描述内容
   - 测试函数名描述测试内容
   
3. **逻辑分组**
   - 相关测试放在同一文件
   - 使用 @Suite 进一步组织
   
4. **独立性**
   - 每个测试独立运行
   - 无跨文件依赖

---

## 📚 相关文档

- 📊 [TEST_REPORT.md](TEST_REPORT.md) - 完整测试报告
- 🔧 [TESTABILITY_IMPROVEMENTS.md](TESTABILITY_IMPROVEMENTS.md) - 改进方案
- 📋 [TEST_QUICK_REFERENCE.md](TEST_QUICK_REFERENCE.md) - 速查表
- 📝 [TESTING_SUMMARY.md](TESTING_SUMMARY.md) - 工作总结

---

**文档版本**: 1.0  
**最后更新**: 2025-11-23  
**测试框架**: SwiftTesting  
**文件数量**: 8 个测试文件
