//
//  SessionStatisticsTests.swift
//  PomodoroTimerTests
//
//  测试会话统计功能
//

import Testing
import Foundation
@testable import PomodoroTimer

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
