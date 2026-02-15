//
//  ChoreScheduler.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import Foundation

/// 家事スケジュールの日付計算を担当するサービス
/// - 完了時の次回予定日計算
/// - 予定日の手動変更（前倒し・後ろ倒し）
struct ChoreScheduler {

    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    // MARK: - 完了時の次回予定日計算

    /// 家事を完了としてマークし、次回予定日を計算する
    /// - Parameters:
    ///   - item: 対象の家事項目
    ///   - completionDate: 完了日（省略時は今日）
    /// - Note: 次回予定日 = 完了日 + 頻度（日数）
    func markAsCompleted(_ item: ChoreItem, on completionDate: Date = Date()) {
        let completionDay = calendar.startOfDay(for: completionDate)

        // 前回完了日を更新
        item.lastCompletedDate = completionDay

        // 次回予定日を計算: 完了日 + 頻度
        item.nextDueDate = calculateNextDueDate(
            from: completionDay,
            frequencyDays: item.frequencyDays
        )

        // 更新日時を記録
        item.updatedAt = Date()
    }

    /// 次回予定日を計算する
    /// - Parameters:
    ///   - baseDate: 基準日
    ///   - frequencyDays: 頻度（日数）
    /// - Returns: 次回予定日
    func calculateNextDueDate(from baseDate: Date, frequencyDays: Int) -> Date {
        let baseDay = calendar.startOfDay(for: baseDate)
        guard let nextDate = calendar.date(byAdding: .day, value: frequencyDays, to: baseDay) else {
            // フォールバック: 計算に失敗した場合は基準日をそのまま返す
            return baseDay
        }
        return nextDate
    }

    // MARK: - 予定日の手動変更

    /// 予定日を手動で変更する（カレンダーからのドラッグ等）
    /// - Parameters:
    ///   - item: 対象の家事項目
    ///   - newDueDate: 新しい予定日
    /// - Note: 次回以降のサイクルもこの変更に連動する（完了時に新しい予定日が基準となる）
    func reschedule(_ item: ChoreItem, to newDueDate: Date) {
        item.nextDueDate = calendar.startOfDay(for: newDueDate)
        item.updatedAt = Date()
    }

    /// 予定日を指定日数分ずらす
    /// - Parameters:
    ///   - item: 対象の家事項目
    ///   - days: ずらす日数（正: 後ろ倒し、負: 前倒し）
    func adjustDueDate(_ item: ChoreItem, byDays days: Int) {
        guard let newDate = calendar.date(byAdding: .day, value: days, to: item.nextDueDate) else {
            return
        }
        item.nextDueDate = newDate
        item.updatedAt = Date()
    }

    // MARK: - 判定ヘルパー

    /// 指定日が予定日かどうかを判定
    /// - Parameters:
    ///   - date: 判定対象の日付
    ///   - item: 家事項目
    /// - Returns: 予定日であれば true
    func isDueDate(_ date: Date, for item: ChoreItem) -> Bool {
        calendar.isDate(date, inSameDayAs: item.nextDueDate)
    }

    /// 今日の家事一覧を取得
    /// - Parameter items: 全家事項目
    /// - Returns: 今日が予定日の家事一覧
    func todayChores(from items: [ChoreItem]) -> [ChoreItem] {
        let today = calendar.startOfDay(for: Date())
        return items.filter { calendar.isDate($0.nextDueDate, inSameDayAs: today) }
    }

    /// 期限切れの家事一覧を取得
    /// - Parameter items: 全家事項目
    /// - Returns: 期限を過ぎている家事一覧
    func overdueChores(from items: [ChoreItem]) -> [ChoreItem] {
        let today = calendar.startOfDay(for: Date())
        return items.filter { $0.nextDueDate < today }
    }

    /// 指定期間内の家事一覧を取得
    /// - Parameters:
    ///   - items: 全家事項目
    ///   - startDate: 開始日
    ///   - endDate: 終了日
    /// - Returns: 期間内に予定されている家事一覧
    func chores(from items: [ChoreItem], inRange startDate: Date, to endDate: Date) -> [ChoreItem] {
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        return items.filter { item in
            let dueDay = calendar.startOfDay(for: item.nextDueDate)
            return dueDay >= start && dueDay <= end
        }
    }
}
