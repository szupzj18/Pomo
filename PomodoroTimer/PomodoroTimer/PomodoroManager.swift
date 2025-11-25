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
    private var isSessionsLoaded = false
    
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
        guard !isRunning else { return }
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
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
        
        if timeRemaining <= 0 {
            completeSession()
        }
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
        notificationService.requestPermission { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveSessions() {
        guard isSessionsLoaded else { return }
        
        do {
            try storage.save(sessions)
        } catch {
            print("Error saving sessions: \(error)")
        }
    }
    
    private func loadSessions() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                let loadedSessions = try self.storage.load()
                DispatchQueue.main.async {
                    // Merge loaded sessions with any new sessions created during load
                    let currentSessions = self.sessions
                    self.sessions = loadedSessions + currentSessions
                    self.isSessionsLoaded = true
                    
                    // If new sessions were added during load, save the merged list
                    if !currentSessions.isEmpty {
                        self.saveSessions()
                    }
                }
            } catch {
                print("Error loading sessions: \(error)")
                DispatchQueue.main.async {
                    self.isSessionsLoaded = true
                }
            }
        }
    }
}
