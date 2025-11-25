import Foundation
import SwiftUI

class HeatmapViewModel: ObservableObject {
    // Visual constants
    let cellSize: CGFloat = 12
    let cellSpacing: CGFloat = 3
    
    let columns = 7 // Days in a week (Rows in the UI)
    let totalWeeks = 12 // Columns in the UI
    
    private let calendar = Calendar.current
    // Cache start date to avoid recalculating every frame
    private lazy var startDate: Date = calculateStartDate()
    
    init() {}
    
    func sessionCount(for date: Date, using manager: PomodoroManager) -> Int {
        // Use the O(1) lookup from manager
        // We create a lightweight session object just to generate the key
        // This is much faster than filtering the array
        let session = PomodoroSession(date: date, type: .work)
        return manager.dailyStats[session.dayKey] ?? 0
    }
    
    func date(for week: Int, day: Int) -> Date {
        // week: 0..11 (column)
        // day: 0..6 (row)
        
        let daysToAdd = (week * 7) + day
        return calendar.date(byAdding: .day, value: daysToAdd, to: startDate) ?? startDate
    }
    
    private func calculateStartDate() -> Date {
        let today = Date()
        // Find the start of the current week based on user's locale
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = calendar.firstWeekday
        
        guard let currentWeekStart = calendar.date(from: components) else {
            return today
        }
        
        // We want to show `totalWeeks` columns.
        // The last column (index totalWeeks-1) should represent the current week.
        // So we go back (totalWeeks - 1) weeks to find the start of column 0.
        return calendar.date(byAdding: .weekOfYear, value: -(totalWeeks - 1), to: currentWeekStart) ?? currentWeekStart
    }
    
    func dayLabel(for row: Int) -> String? {
        let isMondayFirst = calendar.firstWeekday == 2
        
        if isMondayFirst {
            switch row {
            case 0: return "一"
            case 2: return "三"
            case 4: return "五"
            default: return nil
            }
        } else {
            switch row {
            case 1: return "一"
            case 3: return "三"
            case 5: return "五"
            default: return nil
            }
        }
    }
    
    func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color(NSColor.systemGray).opacity(0.1)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3: return Color.green.opacity(0.7)
        case 4: return Color.green.opacity(0.9)
        default: return Color(NSColor.systemGray).opacity(0.1)
        }
    }
    
    func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return colorForLevel(0)
        case 1: return colorForLevel(1)
        case 2: return colorForLevel(2)
        case 3...4: return colorForLevel(3)
        default: return colorForLevel(4)
        }
    }
}
