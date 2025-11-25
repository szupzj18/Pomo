import SwiftUI

struct HeatmapView: View {
    @EnvironmentObject var manager: PomodoroManager
    @StateObject private var viewModel: HeatmapViewModel
    
    init() {
        // Initialize ViewModel without manager dependency
        // Manager is passed to ViewModel methods when needed
        _viewModel = StateObject(wrappedValue: HeatmapViewModel())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("活动热力图")
                .font(.headline)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: viewModel.cellSpacing) {
                    // Heatmap grid
                    HStack(alignment: .top, spacing: viewModel.cellSpacing) {
                        // Day labels (rows)
                        VStack(spacing: viewModel.cellSpacing) {
                            ForEach(0..<viewModel.columns, id: \.self) { row in
                                if let label = viewModel.dayLabel(for: row) {
                                    Text(label)
                                        .font(.system(size: 8))
                                        .frame(width: 30, height: viewModel.cellSize, alignment: .trailing)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("")
                                        .frame(width: 30, height: viewModel.cellSize)
                                }
                            }
                        }
                        
                        // Grid cells
                        ForEach(0..<viewModel.totalWeeks, id: \.self) { week in
                            VStack(spacing: viewModel.cellSpacing) {
                                ForEach(0..<viewModel.columns, id: \.self) { day in
                                    let date = viewModel.date(for: week, day: day)
                                    // Look up count directly from manager via viewModel helper
                                    // Note: manager is observed by View, so changes trigger redraw
                                    let count = viewModel.sessionCount(for: date, using: manager)
                                    
                                    HeatmapCell(
                                        count: count,
                                        date: date,
                                        color: viewModel.colorForCount(count)
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
                    .fill(viewModel.colorForLevel(level))
                        .frame(width: viewModel.cellSize, height: viewModel.cellSize)
                }
                
                Text("多")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
    }
}

struct HeatmapCell: View {
    let count: Int
    let date: Date
    let color: Color
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
    
    private var tooltipText: String {
        // Use a static formatter for performance
        let dateString = DateFormatter.sharedCN.string(from: date)
        return "\(dateString): \(count) 个番茄钟"
    }
}

// Performance optimization for DateFormatter
extension DateFormatter {
    static let sharedCN: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
}

#Preview {
    HeatmapView()
        .environmentObject(PomodoroManager())
        .frame(width: 320)
        .padding()
}
