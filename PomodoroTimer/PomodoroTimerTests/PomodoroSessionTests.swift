//
//  PomodoroSessionTests.swift
//  PomodoroTimerTests
//
//  测试 PomodoroSession 数据模型
//

import Testing
import Foundation
@testable import PomodoroTimer

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
