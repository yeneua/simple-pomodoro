import SwiftUI
import UserNotifications

@Observable
final class PomodoroTimer {
    private(set) var total: TimeInterval = 0
    private(set) var isRunning = false
    private(set) var isDone = false
    private var endDate = Date()
    private var pausedRemaining: TimeInterval?

    var isPaused: Bool { pausedRemaining != nil }

    func remaining(at now: Date) -> TimeInterval {
        pausedRemaining ?? max(0, endDate.timeIntervalSince(now))
    }

    func start(minutes: Int) {
        total = TimeInterval(minutes * 60)
        endDate = .now + total
        pausedRemaining = nil
        isDone = false
        isRunning = true
        Notifier.schedule(after: total)
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func togglePause() {
        if let left = pausedRemaining {
            endDate = .now + left
            pausedRemaining = nil
            Notifier.schedule(after: left)
        } else {
            pausedRemaining = remaining(at: .now)
            Notifier.cancel()
        }
    }

    func finish() {
        guard isRunning, !isDone else { return }
        isDone = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func stop() {
        isRunning = false
        isDone = false
        pausedRemaining = nil
        Notifier.cancel()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

/// 종료 알림. 앱이 백그라운드여도 시간이 되면 소리가 난다.
enum Notifier {
    private static let id = "pomodoro.end"

    static func schedule(after seconds: TimeInterval) {
        cancel()
        guard seconds > 0 else { return }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
        let content = UNMutableNotificationContent()
        // 앱 이름(SimPo)은 iOS가 알림 위에 따로 보여준다
        content.title = "시간이 다 됐어요"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    static func cancel() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }
}
