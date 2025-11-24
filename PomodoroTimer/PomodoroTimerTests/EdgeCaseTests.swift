//
//  EdgeCaseTests.swift
//  PomodoroTimerTests
//
//  测试边界情况和异常场景
//

import Testing
import Foundation
@testable import PomodoroTimer

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
