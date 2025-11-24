# 🍅 番茄时钟 (Pomodoro Timer)

一个简洁优雅的 MacOS 菜单栏番茄时钟应用，采用 SwiftUI 构建。

## ✨ 特性

- **菜单栏集成**: 直接在 MacOS 顶部菜单栏显示倒计时，不占用额外空间
- **标准番茄工作法**: 25 分钟工作时间 + 5 分钟休息时间
- **实时进度显示**: 环形进度条直观展示当前番茄钟进度
- **数据持久化**: 自动保存所有完成的番茄钟记录
- **GitHub 风格热力图**: 可视化展示你的生产力趋势
- **系统通知**: 番茄钟完成时自动发送通知提醒
- **统计数据**: 显示今日和总计完成的番茄钟数量

## 🎨 界面预览

- **菜单栏**: 显示当前状态图标和倒计时
- **主界面**: 
  - 大字体倒计时显示
  - 圆形进度条
  - 播放/暂停、重置、跳过按钮
  - 今日和总计番茄钟统计
  - 可折叠的热力图

## 🚀 构建和运行

### 方式 1: 使用 Xcode

1. 打开根目录中的 `Package.swift` 或打开 `PomodoroTimer/PomodoroTimer` 现有 Xcode 工程目录
2. 选择 "PomodoroTimer" scheme
3. 点击运行 (⌘R)

### 方式 2: 使用 Swift Package Manager

```bash
# 构建项目
swift build -c release

# 运行应用
./.build/release/PomodoroTimer
```

### 方式 3: 创建 Xcode 项目

你也可以按照以下步骤创建一个完整的 Xcode 项目：

1. 打开 Xcode
2. 选择 "Create a new Xcode project"
3. 选择 macOS > App
4. 填写项目信息:
   - Product Name: PomodoroTimer
   - Team: 选择你的开发团队
   - Organization Identifier: com.yourname.PomodoroTimer
   - Interface: SwiftUI
   - Language: Swift
5. 将 `PomodoroApp.swift`、`PomodoroManager.swift`、`PomodoroSession.swift`、`PomodoroMenuView.swift`、`HeatmapView.swift` 添加到项目（路径：`PomodoroTimer/PomodoroTimer/`）
6. 在项目设置中:
   - 将 Info.plist 添加到项目（路径：`PomodoroTimer/PomodoroTimer/Info.plist`）
   - 最低部署目标设置为 macOS 13.0 或更高

## 📱 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Xcode 15.0 或更高版本（开发）

## 🎯 使用方法

1. **启动应用**: 应用会出现在菜单栏右上角，显示计时器图标和时间
2. **点击菜单栏图标**: 打开主控制面板
3. **开始番茄钟**: 点击播放按钮开始 25 分钟工作时间
4. **控制计时器**: 
   - 播放/暂停按钮：开始或暂停当前番茄钟
   - 重置按钮：重置当前番茄钟到初始时间
   - 跳过按钮：跳过当前环节（工作或休息）
5. **查看热力图**: 点击"显示热力图"查看你的生产力记录
6. **接收通知**: 当番茄钟完成时，系统会发送通知提醒你

## 📊 数据存储

所有完成的番茄钟记录会自动保存在：
```
~/Documents/pomodoro_sessions.json
```

## 🛠️ 技术栈

- **语言**: Swift 5.9+
- **UI 框架**: SwiftUI
- **数据持久化**: JSON 文件存储
- **通知**: UserNotifications 框架
- **菜单栏**: MenuBarExtra API
- **测试框架**: SwiftTesting

## 🧪 测试

本项目包含全面的单元测试，使用最新的 SwiftTesting 框架。

### 运行测试

**使用 Xcode:**
```bash
# 在 Xcode 中按 ⌘U 运行所有测试
# 或者使用命令行
xcodebuild test -scheme PomodoroTimer
```

**使用 Swift Package Manager:**
```bash
swift test
```

**运行特定测试:**
```bash
# 运行特定测试套件
swift test --filter PomodoroSessionTests

# 运行特定测试用例
swift test --filter testDayKeyFormat
```

### 测试覆盖

- ✅ **37个测试用例** 覆盖核心功能
- ✅ **9个测试套件** 系统化组织
- ✅ **~70%+ 代码覆盖率**

测试套件包括：
- `PomodoroSessionTests` - 数据模型测试
- `PomodoroManagerTests` - 业务逻辑测试
- `SessionStatisticsTests` - 统计功能测试
- `DateCalculationTests` - 日期计算测试
- `TimerProgressTests` - 进度计算测试
- `HeatmapColorTests` - 热力图测试
- `EdgeCaseTests` - 边界情况测试
- `PerformanceTests` - 性能测试

### 测试文档

详细的测试报告和可测试性分析：
- 📊 [测试报告](TEST_REPORT.md) - 完整的测试覆盖率和测试用例说明
- 🔧 [可测试性改进方案](TESTABILITY_IMPROVEMENTS.md) - 架构改进建议和最佳实践
- 📁 [测试文件结构](TEST_FILE_STRUCTURE.md) - 测试文件组织和运行指南
- 📋 [测试速查表](TEST_QUICK_REFERENCE.md) - 快速参考和诊断命令
- 📝 [测试总结](TESTING_SUMMARY.md) - 工作总结和完成情况

## 📝 番茄工作法

番茄工作法是一种时间管理方法：

1. 选择一个待完成的任务
2. 设置 25 分钟的番茄钟
3. 专注工作，不被打断
4. 番茄钟响起时，休息 5 分钟
5. 完成 4 个番茄钟后，休息 15-30 分钟

## 🔧 自定义配置

你可以在 `PomodoroManager.swift` 中修改以下参数：

```swift
private let workDuration: TimeInterval = 25 * 60  // 工作时长（秒）
private let breakDuration: TimeInterval = 5 * 60  // 休息时长（秒）
```

## 📄 License

请参考项目中的 LICENSE 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

享受高效的工作时光！🍅✨
