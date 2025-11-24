import Foundation
@testable import PomodoroTimer

class MockTimer: TimerProtocol {
    var scheduledInterval: TimeInterval?
    var repeats: Bool = false
    var block: ((TimerProtocol) -> Void)?
    var isInvalidated = false
    
    func schedule(interval: TimeInterval, repeats: Bool, block: @escaping (TimerProtocol) -> Void) {
        scheduledInterval = interval
        self.repeats = repeats
        self.block = block
        isInvalidated = false
    }
    
    func invalidate() {
        isInvalidated = true
    }
    
    // Helper to trigger the timer manually
    func fire() {
        block?(self)
    }
}

class MockStorage: StorageProtocol {
    var savedSessions: [PomodoroSession] = []
    var shouldThrowError = false
    
    func save(_ sessions: [PomodoroSession]) throws {
        if shouldThrowError {
            throw NSError(domain: "MockStorage", code: 1, userInfo: nil)
        }
        savedSessions = sessions
    }
    
    func load() throws -> [PomodoroSession] {
        if shouldThrowError {
            throw NSError(domain: "MockStorage", code: 1, userInfo: nil)
        }
        return savedSessions
    }
}

class MockNotificationService: NotificationServiceProtocol {
    var permissionGranted = true
    var requestPermissionCalled = false
    var sentNotifications: [(title: String, body: String)] = []
    
    func requestPermission(completion: @escaping (Bool, Error?) -> Void) {
        requestPermissionCalled = true
        completion(permissionGranted, nil)
    }
    
    func send(title: String, body: String) {
        sentNotifications.append((title, body))
    }
}
