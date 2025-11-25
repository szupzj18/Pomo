import Foundation
import SwiftUI
#if canImport(UserNotifications)
import UserNotifications
#endif

class PomodoroManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 25 * 60 // 25 minutes
    @Published var isRunning = false
    @Published var isWorking = true // true = work, false = break
    @Published var sessions: [PomodoroSession] = [] {
        didSet {
            // Automatically rebuild dailyStats when sessions are set directly (e.g., in tests)
            // rebuildDailyStats() is idempotent, so it's safe to call multiple times
            // Ensure this runs on main thread since dailyStats is @Published
            if Thread.isMainThread {
                rebuildDailyStats()
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.rebuildDailyStats()
                }
            }
        }
    }
    @Published var dailyStats: [String: Int] = [:] // Cache for O(1) lookup
    
    private var timer: TimerProtocol
    private let storage: StorageProtocol
    private let notificationService: NotificationServiceProtocol
    private var isSessionsLoaded = false
    
    // Timer precision handling
    private var sessionEndTime: Date?
    
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
        
        // Set the expected end time based on current remaining time
        sessionEndTime = Date() + timeRemaining
        
        // Use 0.5s interval for better responsiveness while keeping low overhead
        timer.schedule(interval: 0.5, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer.invalidate()
        sessionEndTime = nil
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
        guard let endTime = sessionEndTime else { return }
        let now = Date()
        
        if now >= endTime {
            timeRemaining = 0
            completeSession()
        } else {
            // Calculate remaining time based on target end time
            // This prevents timer drift and handles system sleep correctly
            timeRemaining = endTime.timeIntervalSince(now)
        }
    }
    
    private func completeSession() {
        timer.invalidate()
        isRunning = false
        sessionEndTime = nil
        
        if isWorking {
            // Save completed work session
            let session = PomodoroSession(date: Date(), type: .work)
            addSession(session)
            
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
    
    private func addSession(_ session: PomodoroSession) {
        sessions.append(session)
        updateDailyStats(with: session)
        saveSessions()
    }
    
    private func updateDailyStats(with session: PomodoroSession) {
        guard session.type == .work else { return }
        let key = session.dayKey
        dailyStats[key, default: 0] += 1
    }
    
    private func rebuildDailyStats() {
        var stats: [String: Int] = [:]
        for session in sessions where session.type == .work {
            stats[session.dayKey, default: 0] += 1
        }
        dailyStats = stats
    }
    
    // MARK: - Persistence
    
    private func saveSessions() {
        guard isSessionsLoaded else { return }
        
        // Create a copy for background saving
        let sessionsToSave = sessions
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            do {
                try self.storage.save(sessionsToSave)
            } catch {
                print("Error saving sessions: \(error)")
            }
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
                    self.rebuildDailyStats() // Rebuild cache
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
