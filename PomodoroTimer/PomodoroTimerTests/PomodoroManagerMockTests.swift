import Testing
import Foundation
@testable import PomodoroTimer

@Suite("PomodoroManager Mock Tests")
struct PomodoroManagerMockTests {
    
    @Test("Timer tick decreases time remaining")
    func testTimerTick() {
        let mockTimer = MockTimer()
        // We only inject timer, others use default mocks if we want, but let's be explicit or rely on defaults?
        // The init has defaults for all params.
        let manager = PomodoroManager(timer: mockTimer, storage: MockStorage(), notificationService: MockNotificationService())
        
        manager.timeRemaining = 10
        let initialTime = manager.timeRemaining
        manager.startTimer()
        
        #expect(mockTimer.scheduledInterval == 0.5) // Updated to match new implementation
        #expect(mockTimer.repeats == true)
        
        // Simulate one tick - with timestamp-based implementation, time should decrease
        // Allow small tolerance for timing differences
        mockTimer.fire()
        
        // Time should have decreased (allowing for small timing differences)
        #expect(manager.timeRemaining < initialTime)
        #expect(manager.timeRemaining > initialTime - 1.1) // Should be close to initial - 0.5
    }
    
    @Test("Session completes when time reaches zero")
    func testSessionCompletion() async throws {
        let mockTimer = MockTimer()
        let mockNotification = MockNotificationService()
        let mockStorage = MockStorage()
        
        let manager = PomodoroManager(
            timer: mockTimer,
            storage: mockStorage,
            notificationService: mockNotification
        )
        
        // Wait for async load to complete so saveSessions can work
        try await Task.sleep(for: .milliseconds(100))
        
        manager.isWorking = true
        // Set time to a very small value so it completes quickly
        manager.timeRemaining = 0.1
        manager.startTimer()
        
        // Wait a bit to allow time to pass, then simulate tick
        try await Task.sleep(for: .milliseconds(150))
        mockTimer.fire()
        
        // Should complete session
        #expect(manager.timeRemaining == 5 * 60) // Switched to break
        #expect(manager.isWorking == false)
        #expect(manager.isRunning == false)
        #expect(mockTimer.isInvalidated == true)
        
        // Check storage
        #expect(mockStorage.savedSessions.count == 1)
        #expect(mockStorage.savedSessions.first?.type == .work)
        
        // Check notification
        #expect(mockNotification.sentNotifications.count == 1)
        #expect(mockNotification.sentNotifications.first?.title == "工作完成！")
    }
    
    @Test("Load sessions from storage on init")
    func testLoadSessions() async throws {
        let mockStorage = MockStorage()
        let session = PomodoroSession(date: Date(), type: .work)
        mockStorage.savedSessions = [session]
        
        let manager = PomodoroManager(storage: mockStorage)
        
        // Wait for async load to complete
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(manager.sessions.count == 1)
        #expect(manager.sessions.first?.type == .work)
    }

    @Test("Skip session invalidates timer and toggles state")
    func testSkipSession() {
        let mockTimer = MockTimer()
        let manager = PomodoroManager(timer: mockTimer)
        
        manager.startTimer()
        manager.isWorking = true
        
        manager.skipSession()
        
        #expect(mockTimer.isInvalidated == true)
        #expect(manager.isWorking == false)
        #expect(manager.timeRemaining == 5 * 60)
    }
    
    @Test("Reset timer invalidates timer and resets time")
    func testResetTimer() {
        let mockTimer = MockTimer()
        let manager = PomodoroManager(timer: mockTimer)
        
        manager.startTimer()
        manager.isWorking = true
        manager.timeRemaining = 100
        
        manager.resetTimer()
        
        #expect(mockTimer.isInvalidated == true)
        #expect(manager.timeRemaining == 25 * 60)
    }
    
    @Test("Request notification permission on init")
    func testRequestPermission() {
        let mockNotification = MockNotificationService()
        
        _ = PomodoroManager(notificationService: mockNotification)
        
        #expect(mockNotification.requestPermissionCalled == true)
    }
}
