import Foundation
import SwiftUI
import UserNotifications

class PomodoroManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 25 * 60 // 25 minutes
    @Published var isRunning = false
    @Published var isWorking = true // true = work, false = break
    @Published var sessions: [PomodoroSession] = []
    
    private var timer: Timer?
    private let workDuration: TimeInterval = 25 * 60
    private let breakDuration: TimeInterval = 5 * 60
    
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init() {
        loadSessions()
        requestNotificationPermission()
    }
    
    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        pauseTimer()
        timeRemaining = isWorking ? workDuration : breakDuration
    }
    
    func skipSession() {
        pauseTimer()
        isWorking.toggle()
        timeRemaining = isWorking ? workDuration : breakDuration
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            completeSession()
            return
        }
        timeRemaining -= 1
    }
    
    private func completeSession() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        if isWorking {
            // Save completed work session
            let session = PomodoroSession(date: Date(), type: .work)
            sessions.append(session)
            saveSessions()
            
            sendNotification(title: "工作完成！", body: "是时候休息一下了")
        } else {
            sendNotification(title: "休息结束！", body: "准备开始下一个番茄钟")
        }
        
        // Switch to next session type
        isWorking.toggle()
        timeRemaining = isWorking ? workDuration : breakDuration
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Persistence
    
    private var sessionsURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("pomodoro_sessions.json")
    }
    
    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: sessionsURL)
        } catch {
            print("Error saving sessions: \(error)")
        }
    }
    
    private func loadSessions() {
        guard FileManager.default.fileExists(atPath: sessionsURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: sessionsURL)
            sessions = try JSONDecoder().decode([PomodoroSession].self, from: data)
        } catch {
            print("Error loading sessions: \(error)")
        }
    }
}
