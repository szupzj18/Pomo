import SwiftUI

@main
struct PomodoroApp: App {
    @StateObject private var pomodoroManager = PomodoroManager()
    
    var body: some Scene {
        MenuBarExtra {
            PomodoroMenuView()
                .environmentObject(pomodoroManager)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: pomodoroManager.isWorking ? "timer" : "cup.and.saucer.fill")
                Text(pomodoroManager.timeString)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .menuBarExtraStyle(.window)
    }
}
