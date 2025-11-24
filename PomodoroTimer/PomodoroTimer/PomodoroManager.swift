import Foundation
import SwiftUI
#if canImport(UserNotifications)
import UserNotifications
#endif

class PomodoroManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 25 * 60 // 25 minutes
    @Published var isRunning = false
    @Published var isWorking = true // true = work, false = break
    @Published var sessions: [PomodoroSession] = []
    
    private var timer: TimerProtocol
    private let storage: StorageProtocol
    private let notificationService: NotificationServiceProtocol
    
    private let workDuration: TimeInterval = 25 * 60
    private let breakDuration: TimeInterval = 5 * 60
    
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(
        timer: TimerProtocol = SystemTimer(),
        storage: StorageProtocol = FileStorage(),
        notificationService: NotificationServiceProtocol = SystemNotificationService()
    ) {
        self.timer = timer
        self.storage = storage
        self.notificationService = notificationService
        
        loadSessions()
        requestNotificationPermission()
    }
    
    func startTimer() {
        isRunning = true
        timer.schedule(interval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer.invalidate()
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
        timer.invalidate()
        isRunning = false
        
        if isWorking {
            // Save completed work session
            let session = PomodoroSession(date: Date(), type: .work)
            sessions.append(session)
            saveSessions()
            
            notificationService.send(title: "工作完成！", body: "是时候休息一下了")
        } else {
            notificationService.send(title: "休息结束！", body: "准备开始下一个番茄钟")
        }
        
        // Switch to next session type
        isWorking.toggle()
        timeRemaining = isWorking ? workDuration : breakDuration
    }
    
    private func requestNotificationPermission() {
        notificationService.requestPermission { [weak self] granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            if granted {
                self?.notificationService.send(title: "番茄时钟已启动", body: "点击菜单栏图标开始专注")
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveSessions() {
        do {
            try storage.save(sessions)
        } catch {
            print("Error saving sessions: \(error)")
        }
    }
    
    private func loadSessions() {
        do {
            sessions = try storage.load()
        } catch {
            print("Error loading sessions: \(error)")
        }
    }
}
