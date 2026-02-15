//
//  NotificationService.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import Foundation
import UserNotifications

/// 家事リマインダー通知を管理するサービス
final class NotificationService {

    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Authorization

    /// 通知の許可をリクエスト
    /// - Returns: 許可されたらtrue
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("通知の許可リクエストに失敗: \(error)")
            return false
        }
    }

    /// 現在の通知許可状態を取得
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule Notifications

    /// 家事のリマインダー通知をスケジュール
    /// - Parameters:
    ///   - chore: 対象の家事
    ///   - hour: 通知する時刻（時）デフォルト9時
    ///   - minute: 通知する時刻（分）デフォルト0分
    func scheduleReminder(
        for chore: ChoreItem,
        at hour: Int = 9,
        minute: Int = 0
    ) async throws {
        // 既存の通知を削除
        removeReminder(for: chore)

        // 通知コンテンツを作成
        let content = UNMutableNotificationContent()
        content.title = "家事のリマインダー"
        content.body = "\(chore.name)の予定日です"
        content.sound = .default
        content.categoryIdentifier = "CHORE_REMINDER"
        content.userInfo = ["choreId": chore.id.uuidString]

        // トリガーを作成（予定日の指定時刻）
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: chore.nextDueDate
        )
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        // リクエストを作成
        let request = UNNotificationRequest(
            identifier: notificationId(for: chore),
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    /// 家事のリマインダー通知を削除
    /// - Parameter chore: 対象の家事
    func removeReminder(for chore: ChoreItem) {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [notificationId(for: chore)]
        )
    }

    /// 全ての家事のリマインダーを再スケジュール
    /// - Parameter chores: 全家事一覧
    func rescheduleAllReminders(for chores: [ChoreItem]) async {
        // 全ての通知を削除
        notificationCenter.removeAllPendingNotificationRequests()

        // 今日以降の予定のみ通知をスケジュール
        let today = Calendar.current.startOfDay(for: Date())
        let upcomingChores = chores.filter { $0.nextDueDate >= today }

        for chore in upcomingChores {
            try? await scheduleReminder(for: chore)
        }
    }

    // MARK: - Helper

    /// 家事固有の通知IDを生成
    private func notificationId(for chore: ChoreItem) -> String {
        "chore_reminder_\(chore.id.uuidString)"
    }

    // MARK: - Pending Notifications

    /// スケジュールされている通知一覧を取得
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }
}
