import Foundation

struct PomodoroSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let type: SessionType
    
    init(id: UUID = UUID(), date: Date, type: SessionType) {
        self.id = id
        self.date = date
        self.type = type
    }
    
    enum SessionType: String, Codable {
        case work
        case rest = "break"
    }
}

// Helper extension for grouping sessions by date
extension PomodoroSession {
    var dayKey: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            // Fallback to ISO8601 format if components extraction fails
            let formatter = ISO8601DateFormatter()
            return formatter.string(from: date)
        }
        return "\(year)-\(month)-\(day)"
    }
}
