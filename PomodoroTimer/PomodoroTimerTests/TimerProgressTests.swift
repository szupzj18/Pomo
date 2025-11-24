//
//  TimerProgressTests.swift
//  PomodoroTimerTests
//
//  测试计时器进度计算
//

import Testing
import Foundation
@testable import PomodoroTimer

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
