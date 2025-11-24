//
//  DateCalculationTests.swift
//  PomodoroTimerTests
//
//  测试日期计算功能
//

import Testing
import Foundation
@testable import PomodoroTimer

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
