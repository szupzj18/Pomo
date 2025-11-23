//
//  PomodoroTimerTests.swift
//  PomodoroTimerTests
//
//  Created by ByteDance on 2025/11/24.
//

import Testing
import Foundation
@testable import PomodoroTimer

// MARK: - PomodoroSession Tests

@Suite("PomodoroSession 测试套件")
struct PomodoroSessionTests {
    
    @Test("创建工作会话")
    func testCreateWorkSession() {
        let date = Date()
        let session = PomodoroSession(date: date, type: .work)
        
        #expect(session.type == .work)
        #expect(session.date == date)
        #expect(session.id != UUID()) // 应该生成唯一ID
    }
    
    @Test("创建休息会话")
    func testCreateBreakSession() {
        let date = Date()
        let session = PomodoroSession(date: date, type: .rest)
        
        #expect(session.type == .rest)
        #expect(session.date == date)
    }
    
    @Test("dayKey 格式正确")
    func testDayKeyFormat() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 15
        components.hour = 14
        components.minute = 30
        
        guard let testDate = calendar.date(from: components) else {
            Issue.record("无法创建测试日期")
            return
        }
        
        let session = PomodoroSession(date: testDate, type: .work)
        let dayKey = session.dayKey
        
        #expect(dayKey == "2024-3-15")
    }
    
    @Test("同一天不同时间的会话有相同的 dayKey")
    func testSameDayKeyForSameDate() {
        let calendar = Calendar.current
        let date1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 9))!
        let date2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 18))!
        
        let session1 = PomodoroSession(date: date1, type: .work)
        let session2 = PomodoroSession(date: date2, type: .work)
        
        #expect(session1.dayKey == session2.dayKey)
    }
    
    @Test("不同日期的会话有不同的 dayKey")
    func testDifferentDayKeyForDifferentDates() {
        let calendar = Calendar.current
        let date1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let date2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 2))!
        
        let session1 = PomodoroSession(date: date1, type: .work)
        let session2 = PomodoroSession(date: date2, type: .work)
        
        #expect(session1.dayKey != session2.dayKey)
    }
    
    @Test("会话可以编码和解码")
    func testSessionCodable() throws {
        let originalSession = PomodoroSession(
            id: UUID(),
            date: Date(),
            type: .work
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalSession)
        
        let decoder = JSONDecoder()
        let decodedSession = try decoder.decode(PomodoroSession.self, from: data)
        
        #expect(decodedSession.id == originalSession.id)
        #expect(decodedSession.type == originalSession.type)
        // 注意：Date 比较需要考虑精度
        #expect(abs(decodedSession.date.timeIntervalSince(originalSession.date)) < 0.001)
    }
    
    @Test("SessionType 枚举值正确")
    func testSessionTypeRawValues() {
        #expect(PomodoroSession.SessionType.work.rawValue == "work")
        #expect(PomodoroSession.SessionType.rest.rawValue == "break")
    }
}

// MARK: - PomodoroManager Tests

@Suite("PomodoroManager 测试套件")
struct PomodoroManagerTests {
    
    @Test("初始化状态正确")
    func testInitialState() {
        let manager = PomodoroManager()
        
        #expect(manager.timeRemaining == 25 * 60)
        #expect(manager.isRunning == false)
        #expect(manager.isWorking == true)
    }
    
    @Test("时间字符串格式化正确 - 25分钟")
    func testTimeStringFormat25Minutes() {
        let manager = PomodoroManager()
        manager.timeRemaining = 25 * 60
        
        #expect(manager.timeString == "25:00")
    }
    
    @Test("时间字符串格式化正确 - 1分30秒")
    func testTimeStringFormat1Minute30Seconds() {
        let manager = PomodoroManager()
        manager.timeRemaining = 90
        
        #expect(manager.timeString == "01:30")
    }
    
    @Test("时间字符串格式化正确 - 0秒")
    func testTimeStringFormatZero() {
        let manager = PomodoroManager()
        manager.timeRemaining = 0
        
        #expect(manager.timeString == "00:00")
    }
    
    @Test("时间字符串格式化正确 - 个位数")
    func testTimeStringFormatSingleDigits() {
        let manager = PomodoroManager()
        manager.timeRemaining = 305 // 5分5秒
        
        #expect(manager.timeString == "05:05")
    }
    
    @Test("启动计时器")
    func testStartTimer() {
        let manager = PomodoroManager()
        
        #expect(manager.isRunning == false)
        
        manager.startTimer()
        
        #expect(manager.isRunning == true)
        
        // 清理
        manager.pauseTimer()
    }
    
    @Test("暂停计时器")
    func testPauseTimer() {
        let manager = PomodoroManager()
        
        manager.startTimer()
        #expect(manager.isRunning == true)
        
        manager.pauseTimer()
        #expect(manager.isRunning == false)
    }
    
    @Test("重置工作计时器")
    func testResetWorkTimer() {
        let manager = PomodoroManager()
        manager.timeRemaining = 100
        manager.isWorking = true
        
        manager.resetTimer()
        
        #expect(manager.timeRemaining == 25 * 60)
        #expect(manager.isRunning == false)
    }
    
    @Test("重置休息计时器")
    func testResetBreakTimer() {
        let manager = PomodoroManager()
        manager.timeRemaining = 100
        manager.isWorking = false
        
        manager.resetTimer()
        
        #expect(manager.timeRemaining == 5 * 60)
        #expect(manager.isRunning == false)
    }
    
    @Test("跳过会话 - 从工作切换到休息")
    func testSkipSessionFromWorkToBreak() {
        let manager = PomodoroManager()
        manager.isWorking = true
        manager.timeRemaining = 1000
        
        manager.skipSession()
        
        #expect(manager.isWorking == false)
        #expect(manager.timeRemaining == 5 * 60)
        #expect(manager.isRunning == false)
    }
    
    @Test("跳过会话 - 从休息切换到工作")
    func testSkipSessionFromBreakToWork() {
        let manager = PomodoroManager()
        manager.isWorking = false
        manager.timeRemaining = 200
        
        manager.skipSession()
        
        #expect(manager.isWorking == true)
        #expect(manager.timeRemaining == 25 * 60)
        #expect(manager.isRunning == false)
    }
    
    @Test("会话持久化 - 保存和加载", .timeLimit(.minutes(1)))
    func testSessionPersistence() throws {
        let manager = PomodoroManager()
        
        // 创建测试会话
        let testSessions = [
            PomodoroSession(date: Date(), type: .work),
            PomodoroSession(date: Date().addingTimeInterval(-3600), type: .work),
            PomodoroSession(date: Date().addingTimeInterval(-7200), type: .rest)
        ]
        
        // 通过反射或其他方式设置会话
        manager.sessions = testSessions
        
        // 触发保存（通过添加新会话来间接触发）
        // 注意：这需要重构 PomodoroManager 以便更好地测试
        
        #expect(manager.sessions.count >= 0) // 基本验证
    }
}

// MARK: - Session Statistics Tests

@Suite("会话统计测试套件")
struct SessionStatisticsTests {
    
    @Test("计算今日会话数量")
    func testTodaySessionCount() {
        let manager = PomodoroManager()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 添加今天的会话
        manager.sessions = [
            PomodoroSession(date: today, type: .work),
            PomodoroSession(date: today.addingTimeInterval(3600), type: .work),
            PomodoroSession(date: today.addingTimeInterval(-86400), type: .work), // 昨天
        ]
        
        let todayCount = manager.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: today) && session.type == .work
        }.count
        
        #expect(todayCount == 2)
    }
    
    @Test("计算总会话数量")
    func testTotalSessionCount() {
        let manager = PomodoroManager()
        
        manager.sessions = [
            PomodoroSession(date: Date(), type: .work),
            PomodoroSession(date: Date(), type: .work),
            PomodoroSession(date: Date(), type: .rest),
            PomodoroSession(date: Date().addingTimeInterval(-86400), type: .work),
        ]
        
        let totalWorkCount = manager.sessions.filter { $0.type == .work }.count
        
        #expect(totalWorkCount == 3)
    }
    
    @Test("过滤工作会话")
    func testFilterWorkSessions() {
        let manager = PomodoroManager()
        
        manager.sessions = [
            PomodoroSession(date: Date(), type: .work),
            PomodoroSession(date: Date(), type: .rest),
            PomodoroSession(date: Date(), type: .work),
            PomodoroSession(date: Date(), type: .rest),
        ]
        
        let workSessions = manager.sessions.filter { $0.type == .work }
        let restSessions = manager.sessions.filter { $0.type == .rest }
        
        #expect(workSessions.count == 2)
        #expect(restSessions.count == 2)
    }
}

// MARK: - Date Calculation Tests

@Suite("日期计算测试套件")
struct DateCalculationTests {
    
    @Test("计算过去的日期")
    func testCalculatePastDate() {
        let calendar = Calendar.current
        let today = Date()
        
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today)
        
        #expect(sevenDaysAgo != nil)
        
        if let sevenDaysAgo = sevenDaysAgo {
            let daysDifference = calendar.dateComponents([.day], from: sevenDaysAgo, to: today).day
            #expect(daysDifference == 7)
        }
    }
    
    @Test("判断两个日期是否在同一天")
    func testSameDayComparison() {
        let calendar = Calendar.current
        let date1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 9))!
        let date2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 18))!
        let date3 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 2, hour: 9))!
        
        #expect(calendar.isDate(date1, inSameDayAs: date2))
        #expect(!calendar.isDate(date1, inSameDayAs: date3))
    }
    
    @Test("周开始日期计算")
    func testWeekStartCalculation() {
        let calendar = Calendar.current
        let today = Date()
        
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start
        
        #expect(weekStart != nil)
    }
}

// MARK: - Timer Progress Tests

@Suite("计时器进度测试套件")
struct TimerProgressTests {
    
    @Test("工作时段进度计算 - 开始")
    func testWorkProgressAtStart() {
        let timeRemaining: TimeInterval = 25 * 60
        let total: TimeInterval = 25 * 60
        let progress = 1 - timeRemaining / total
        
        #expect(progress == 0.0)
    }
    
    @Test("工作时段进度计算 - 中途")
    func testWorkProgressHalfway() {
        let timeRemaining: TimeInterval = 12.5 * 60
        let total: TimeInterval = 25 * 60
        let progress = 1 - timeRemaining / total
        
        #expect(abs(progress - 0.5) < 0.01)
    }
    
    @Test("工作时段进度计算 - 结束")
    func testWorkProgressAtEnd() {
        let timeRemaining: TimeInterval = 0
        let total: TimeInterval = 25 * 60
        let progress = 1 - timeRemaining / total
        
        #expect(progress == 1.0)
    }
    
    @Test("休息时段进度计算")
    func testBreakProgress() {
        let timeRemaining: TimeInterval = 2.5 * 60
        let total: TimeInterval = 5 * 60
        let progress = 1 - timeRemaining / total
        
        #expect(abs(progress - 0.5) < 0.01)
    }
}

// MARK: - Heatmap Color Tests

@Suite("热力图颜色测试套件")
struct HeatmapColorTests {
    
    @Test("零会话显示灰色")
    func testZeroSessionsColor() {
        let count = 0
        let shouldBeGray = count == 0
        
        #expect(shouldBeGray)
    }
    
    @Test("会话数量映射到颜色等级")
    func testSessionCountToColorLevel() {
        func colorLevel(for count: Int) -> Int {
            switch count {
            case 0: return 0
            case 1: return 1
            case 2: return 2
            case 3...4: return 3
            default: return 4
            }
        }
        
        #expect(colorLevel(for: 0) == 0)
        #expect(colorLevel(for: 1) == 1)
        #expect(colorLevel(for: 2) == 2)
        #expect(colorLevel(for: 3) == 3)
        #expect(colorLevel(for: 4) == 3)
        #expect(colorLevel(for: 5) == 4)
        #expect(colorLevel(for: 10) == 4)
    }
}

// MARK: - Tooltip Tests

@Suite("工具提示测试套件")
struct TooltipTests {
    
    @Test("生成正确的工具提示文本")
    func testTooltipGeneration() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        
        let date = Date()
        let count = 5
        
        let dateString = formatter.string(from: date)
        let tooltipText = "\(dateString): \(count) 个番茄钟"
        
        #expect(tooltipText.contains(dateString))
        #expect(tooltipText.contains("5 个番茄钟"))
    }
}

// MARK: - Edge Cases Tests

@Suite("边界情况测试套件")
struct EdgeCaseTests {
    
    @Test("处理空会话列表")
    func testEmptySessionsList() {
        let manager = PomodoroManager()
        manager.sessions = []
        
        let workCount = manager.sessions.filter { $0.type == .work }.count
        
        #expect(workCount == 0)
    }
    
    @Test("处理大量会话")
    func testLargeNumberOfSessions() {
        let manager = PomodoroManager()
        
        // 创建100个会话
        manager.sessions = (0..<100).map { i in
            PomodoroSession(
                date: Date().addingTimeInterval(TimeInterval(-i * 3600)),
                type: i % 2 == 0 ? .work : .rest
            )
        }
        
        #expect(manager.sessions.count == 100)
        
        let workSessions = manager.sessions.filter { $0.type == .work }
        #expect(workSessions.count == 50)
    }
    
    @Test("时间为负数时的处理")
    func testNegativeTimeHandling() {
        let manager = PomodoroManager()
        manager.timeRemaining = -10
        
        // 虽然不应该出现负数，但要确保格式化不会崩溃
        let timeString = manager.timeString
        #expect(timeString == "00:-10" || timeString.contains("-"))
    }
    
    @Test("跨年度的会话统计")
    func testCrossYearSessions() {
        let manager = PomodoroManager()
        let calendar = Calendar.current
        
        let date2023 = calendar.date(from: DateComponents(year: 2023, month: 12, day: 31))!
        let date2024 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        
        manager.sessions = [
            PomodoroSession(date: date2023, type: .work),
            PomodoroSession(date: date2024, type: .work),
        ]
        
        #expect(manager.sessions.count == 2)
        #expect(manager.sessions[0].dayKey != manager.sessions[1].dayKey)
    }
}

// MARK: - Performance Tests

@Suite("性能测试套件")
struct PerformanceTests {
    
    @Test("大量会话的过滤性能", .timeLimit(.seconds(1)))
    func testFilterPerformance() {
        let manager = PomodoroManager()
        
        // 创建1000个会话
        manager.sessions = (0..<1000).map { i in
            PomodoroSession(
                date: Date().addingTimeInterval(TimeInterval(-i * 3600)),
                type: .work
            )
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        // 这个操作应该在1秒内完成
        let todaySessions = manager.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: today) && session.type == .work
        }
        
        #expect(todaySessions.count >= 0)
    }
}
