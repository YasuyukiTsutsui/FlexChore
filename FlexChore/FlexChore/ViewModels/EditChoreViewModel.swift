//
//  EditChoreViewModel.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import Foundation
import Observation
import os

/// 家事編集画面のViewModel
@Observable
final class EditChoreViewModel {
    // MARK: - Dependencies

    private let scheduler: ChoreScheduler
    private let notificationService: NotificationService
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "FlexChore", category: "EditChoreViewModel")

    // MARK: - Original State (for comparison)

    private let originalChore: ChoreItem
    private var originalName: String
    private var originalFrequencyDays: Int
    private var originalNextDueDate: Date

    // MARK: - Editable State

    var name: String
    var frequencyDays: Int
    var nextDueDate: Date

    // MARK: - Initialization

    init(
        chore: ChoreItem,
        scheduler: ChoreScheduler = ChoreScheduler(),
        notificationService: NotificationService = .shared
    ) {
        self.originalChore = chore
        self.scheduler = scheduler
        self.notificationService = notificationService

        // 元の値を保存
        self.originalName = chore.name
        self.originalFrequencyDays = chore.frequencyDays
        self.originalNextDueDate = chore.nextDueDate

        // 編集用の値を初期化
        self.name = chore.name
        self.frequencyDays = chore.frequencyDays
        self.nextDueDate = chore.nextDueDate
    }

    // MARK: - Computed Properties

    /// 変更があるかどうか
    var hasChanges: Bool {
        name != originalName ||
        frequencyDays != originalFrequencyDays ||
        !Calendar.current.isDate(nextDueDate, inSameDayAs: originalNextDueDate)
    }

    /// トリミング済みの名前
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    /// 入力が有効かどうか
    var isValid: Bool {
        !trimmedName.isEmpty && frequencyDays > 0
    }

    /// 保存可能かどうか（変更があり、かつ有効な入力）
    var canSave: Bool {
        hasChanges && isValid
    }

    /// バリデーションエラー
    var validationErrors: [String] {
        var errors: [String] = []

        if trimmedName.isEmpty {
            errors.append("家事の名前を入力してください")
        }

        if frequencyDays <= 0 {
            errors.append("頻度は1日以上に設定してください")
        }

        return errors
    }

    /// 予定日が変更されたかどうか
    var dueDateChanged: Bool {
        !Calendar.current.isDate(nextDueDate, inSameDayAs: originalNextDueDate)
    }

    // MARK: - Actions

    /// 変更を保存
    func save() async {
        guard isValid else { return }

        // 名前を更新
        if name != originalName {
            originalChore.name = trimmedName
        }

        // 頻度を更新
        if frequencyDays != originalFrequencyDays {
            originalChore.frequencyDays = frequencyDays
        }

        // 予定日を更新（リスケジュール）
        if dueDateChanged {
            scheduler.reschedule(originalChore, to: nextDueDate)

            // 通知も更新
            do {
                try await notificationService.scheduleReminder(for: originalChore)
            } catch {
                logger.error("通知スケジュールに失敗 (\(self.originalChore.name)): \(error.localizedDescription)")
            }
        }

        originalChore.updatedAt = Date()

        // 元の値を更新
        originalName = originalChore.name
        originalFrequencyDays = originalChore.frequencyDays
        originalNextDueDate = originalChore.nextDueDate
    }

    /// 変更を破棄して元に戻す
    func revert() {
        name = originalName
        frequencyDays = originalFrequencyDays
        nextDueDate = originalNextDueDate
    }

    // MARK: - Quick Actions

    /// 予定日を1日後ろ倒し
    func postponeOneDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: nextDueDate) {
            nextDueDate = newDate
        }
    }

    /// 予定日を1日前倒し
    func bringForwardOneDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: nextDueDate) {
            nextDueDate = newDate
        }
    }

    /// 予定日を今日に設定
    func setDueToday() {
        nextDueDate = Calendar.current.startOfDay(for: Date())
    }

    /// 予定日を明日に設定
    func setDueTomorrow() {
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            nextDueDate = Calendar.current.startOfDay(for: tomorrow)
        }
    }
}
