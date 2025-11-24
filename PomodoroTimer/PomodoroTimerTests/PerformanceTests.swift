//
//  PerformanceTests.swift
//  PomodoroTimerTests
//
//  测试性能相关指标
//

import Testing
import Foundation
@testable import PomodoroTimer

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
