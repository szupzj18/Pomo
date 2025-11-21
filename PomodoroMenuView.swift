import SwiftUI

struct PomodoroMenuView: View {
    @EnvironmentObject var manager: PomodoroManager
    @State private var showHeatmap = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Timer Section
            VStack(spacing: 16) {
                // Session Type Indicator
                Text(manager.isWorking ? "🍅 工作时间" : "☕️ 休息时间")
                    .font(.headline)
                    .foregroundColor(manager.isWorking ? .red : .green)
                
                // Timer Display
                Text(manager.timeString)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            manager.isWorking ? Color.red : Color.green,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: progress)
                    
                    VStack {
                        Image(systemName: manager.isWorking ? "brain.head.profile" : "cup.and.saucer.fill")
                            .font(.system(size: 30))
                            .foregroundColor(manager.isWorking ? .red : .green)
                    }
                }
                
                // Control Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        if manager.isRunning {
                            manager.pauseTimer()
                        } else {
                            manager.startTimer()
                        }
                    }) {
                        Image(systemName: manager.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))
                            .frame(width: 44, height: 44)
                            .background(manager.isRunning ? Color.orange : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        manager.resetTimer()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        manager.skipSession()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                
                // Today's Stats
                HStack(spacing: 20) {
                    VStack {
                        Text("\(todaySessionCount)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.red)
                        Text("今日番茄")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack {
                        Text("\(totalSessionCount)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.blue)
                        Text("总计番茄")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            
            Divider()
            
            // Heatmap Toggle Button
            Button(action: {
                showHeatmap.toggle()
            }) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                    Text(showHeatmap ? "隐藏热力图" : "显示热力图")
                    Spacer()
                    Image(systemName: showHeatmap ? "chevron.up" : "chevron.down")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if showHeatmap {
                HeatmapView()
                    .environmentObject(manager)
                    .padding()
                    .transition(.opacity)
            }
            
            Divider()
            
            // Quit Button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text("退出")
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 320)
    }
    
    private var progress: CGFloat {
        let total = manager.isWorking ? 25 * 60.0 : 5 * 60.0
        return CGFloat(1 - manager.timeRemaining / total)
    }
    
    private var todaySessionCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return manager.sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: today) && session.type == .work
        }.count
    }
    
    private var totalSessionCount: Int {
        manager.sessions.filter { $0.type == .work }.count
    }
}

#Preview {
    PomodoroMenuView()
        .environmentObject(PomodoroManager())
}
