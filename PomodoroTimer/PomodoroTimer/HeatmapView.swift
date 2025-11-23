import SwiftUI

struct HeatmapView: View {
    @EnvironmentObject var manager: PomodoroManager
    
    private let columns = 7 // Days in a week
    private let cellSize: CGFloat = 12
    private let cellSpacing: CGFloat = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("活动热力图")
                .font(.headline)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: cellSpacing) {
                    // Day labels
                    HStack(spacing: cellSpacing) {
                        Text("")
                            .frame(width: 30)
                        ForEach(weekLabels, id: \.self) { label in
                            Text(label)
                                .font(.system(size: 8))
                                .frame(width: cellSize, alignment: .center)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Heatmap grid
                    HStack(alignment: .top, spacing: cellSpacing) {
                        // Month labels
                        VStack(spacing: cellSpacing) {
                            ForEach(0..<columns, id: \.self) { row in
                                if let label = dayLabel(for: row) {
                                    Text(label)
                                        .font(.system(size: 8))
                                        .frame(width: 30, height: cellSize, alignment: .trailing)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("")
                                        .frame(width: 30, height: cellSize)
                                }
                            }
                        }
                        
                        // Grid cells
                        ForEach(0..<totalWeeks, id: \.self) { week in
                            VStack(spacing: cellSpacing) {
                                ForEach(0..<columns, id: \.self) { day in
                                    HeatmapCell(
                                        count: sessionCount(for: week, day: day),
                                        date: date(for: week, day: day)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Legend
            HStack(spacing: 4) {
                Text("少")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                
                ForEach(0..<5, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForLevel(level))
                        .frame(width: cellSize, height: cellSize)
                }
                
                Text("多")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
    }
    
    private var totalWeeks: Int {
        // Show last 12 weeks
        12
    }
    
    private var weekLabels: [String] {
        ["一", "二", "三", "四", "五", "六", "日"]
    }
    
    private func dayLabel(for row: Int) -> String? {
        switch row {
        case 1: return "一"
        case 3: return "三"
        case 5: return "五"
        default: return nil
        }
    }
    
    private func date(for week: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate the start of the week grid (12 weeks ago)
        let weeksAgo = totalWeeks - week - 1
        let daysAgo = weeksAgo * 7 + (6 - day)
        
        return calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
    }
    
    private func sessionCount(for week: Int, day: Int) -> Int {
        let targetDate = date(for: week, day: day)
        let calendar = Calendar.current
        
        return manager.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: targetDate) && session.type == .work
        }.count
    }
    
    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color(NSColor.systemGray).opacity(0.1)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3: return Color.green.opacity(0.7)
        case 4: return Color.green.opacity(0.9)
        default: return Color(NSColor.systemGray).opacity(0.1)
        }
    }
}

struct HeatmapCell: View {
    let count: Int
    let date: Date
    @State private var isHovered = false
    
    private let cellSize: CGFloat = 12
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.primary.opacity(0.2), lineWidth: isHovered ? 1 : 0)
            )
            .help(tooltipText)
            .onHover { hovering in
                isHovered = hovering
            }
    }
    
    private var color: Color {
        switch count {
        case 0: return Color(NSColor.systemGray).opacity(0.1)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3...4: return Color.green.opacity(0.7)
        default: return Color.green.opacity(0.9)
        }
    }
    
    private var tooltipText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        let dateString = formatter.string(from: date)
        return "\(dateString): \(count) 个番茄钟"
    }
}

#Preview {
    HeatmapView()
        .environmentObject(PomodoroManager())
        .frame(width: 320)
        .padding()
}
