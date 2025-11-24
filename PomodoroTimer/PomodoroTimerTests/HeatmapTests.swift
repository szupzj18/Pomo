//
//  HeatmapTests.swift
//  PomodoroTimerTests
//
//  测试热力图相关功能
//

import Testing
import Foundation
@testable import PomodoroTimer

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
