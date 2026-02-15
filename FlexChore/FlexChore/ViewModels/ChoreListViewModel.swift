//
//  ChoreListViewModel.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import Foundation
import SwiftData
import Observation
import os

/// 家事一覧画面のViewModel
@Observable
final class ChoreListViewModel {
    private let scheduler: ChoreScheduler
    private let notificationService: NotificationService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "FlexChore", category: "ChoreListViewModel")
    private var modelContext: ModelContext?

    init(
        scheduler: ChoreScheduler = ChoreScheduler(),
        notificationService: NotificationService = .shared
    ) {
        self.scheduler = scheduler
        self.notificationService = notificationService
    }

    /// ModelContextを設定（Viewから注入）
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Filtering

    /// 期限切れの家事を抽出
    func overdueChores(from chores: [ChoreItem]) -> [ChoreItem] {
        chores.filter { $0.isOverdue }
    }

    /// 今日が予定日の家事を抽出
    func todayChores(from chores: [ChoreItem]) -> [ChoreItem] {
        chores.filter { $0.isDueToday }
    }

    /// 今後の予定（明日以降）の家事を抽出
    func upcomingChores(from chores: [ChoreItem]) -> [ChoreItem] {
        chores.filter { $0.daysUntilDue > 0 }
    }

    // MARK: - Actions

    /// 家事を完了としてマーク
    /// - Parameter chore: 完了する家事
    func completeChore(_ chore: ChoreItem) {
        scheduler.markAsCompleted(chore)

        // 次回予定日の通知をスケジュール
        Task {
            do {
                try await notificationService.scheduleReminder(for: chore)
            } catch {
                logger.error("通知スケジュールに失敗 (\(chore.name)): \(error.localizedDescription)")
            }
        }
    }

    /// 家事を削除
    /// - Parameter chore: 削除する家事
    func deleteChore(_ chore: ChoreItem) {
        // 通知を削除
        notificationService.removeReminder(for: chore)
        modelContext?.delete(chore)
    }

    /// 複数の家事を削除
    /// - Parameters:
    ///   - source: 削除元の配列
    ///   - offsets: 削除するインデックス
    func deleteChores(from source: [ChoreItem], at offsets: IndexSet) {
        for index in offsets {
            guard source.indices.contains(index) else { continue }
            let chore = source[index]
            notificationService.removeReminder(for: chore)
            modelContext?.delete(chore)
        }
    }

    /// 家事の予定日を変更
    /// - Parameters:
    ///   - chore: 対象の家事
    ///   - newDate: 新しい予定日
    func rescheduleChore(_ chore: ChoreItem, to newDate: Date) {
        scheduler.reschedule(chore, to: newDate)

        // 通知を更新
        Task {
            do {
                try await notificationService.scheduleReminder(for: chore)
            } catch {
                logger.error("通知スケジュールに失敗 (\(chore.name)): \(error.localizedDescription)")
            }
        }
    }

    /// 家事の予定日を日数分ずらす
    /// - Parameters:
    ///   - chore: 対象の家事
    ///   - days: ずらす日数（正: 後ろ倒し、負: 前倒し）
    func adjustChoreDate(_ chore: ChoreItem, byDays days: Int) {
        scheduler.adjustDueDate(chore, byDays: days)

        // 通知を更新
        Task {
            do {
                try await notificationService.scheduleReminder(for: chore)
            } catch {
                logger.error("通知スケジュールに失敗 (\(chore.name)): \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Notification Management

    /// 全ての家事の通知を再スケジュール
    func rescheduleAllNotifications(for chores: [ChoreItem]) {
        Task {
            await notificationService.rescheduleAllReminders(for: chores)
        }
    }

    /// 通知の許可をリクエスト
    func requestNotificationPermission() async -> Bool {
        await notificationService.requestAuthorization()
    }
}
