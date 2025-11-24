import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

protocol TimerProtocol {
    func schedule(interval: TimeInterval, repeats: Bool, block: @escaping (TimerProtocol) -> Void)
    func invalidate()
}

class SystemTimer: TimerProtocol {
    private var timer: Timer?
    
    func schedule(interval: TimeInterval, repeats: Bool, block: @escaping (TimerProtocol) -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { [weak self] _ in
            guard let self = self else { return }
            block(self)
        }
    }
    
    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}

protocol StorageProtocol {
    func save(_ sessions: [PomodoroSession]) throws
    func load() throws -> [PomodoroSession]
}

class FileStorage: StorageProtocol {
    private let fileManager = FileManager.default
    
    private var sessionsURL: URL {
        let appSupportPath = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appDirectory = appSupportPath.appendingPathComponent("PomodoroTimer", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        
        return appDirectory.appendingPathComponent("pomodoro_sessions.json")
    }
    
    func save(_ sessions: [PomodoroSession]) throws {
        let data = try JSONEncoder().encode(sessions)
        try data.write(to: sessionsURL)
    }
    
    func load() throws -> [PomodoroSession] {
        guard fileManager.fileExists(atPath: sessionsURL.path) else { return [] }
        let data = try Data(contentsOf: sessionsURL)
        return try JSONDecoder().decode([PomodoroSession].self, from: data)
    }
}

protocol NotificationServiceProtocol {
    func requestPermission(completion: @escaping (Bool, Error?) -> Void)
    func send(title: String, body: String)
}

class SystemNotificationService: NotificationServiceProtocol {
    func requestPermission(completion: @escaping (Bool, Error?) -> Void) {
        #if canImport(UserNotifications)
        guard Bundle.main.bundleURL.pathExtension == "app" else { 
            completion(false, nil)
            return 
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: completion)
        #else
        completion(false, nil)
        #endif
    }
    
    func send(title: String, body: String) {
        #if canImport(UserNotifications)
        guard Bundle.main.bundleURL.pathExtension == "app" else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        #endif
    }
}
