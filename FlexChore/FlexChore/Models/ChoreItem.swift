//
//  ChoreItem.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import Foundation
import SwiftData

/// 家事項目を表すデータモデル
/// - 「予定を柔軟にずらせる」機能をサポート
/// - 「完了日に基づいて次回の予定が自動計算される」機能をサポート
@Model
final class ChoreItem {
    /// 家事の名称（例: "掃除機がけ", "洗濯"）
    var name: String

    /// 頻度（日数単位）
    /// 例: 7 = 週1回、3 = 3日に1回
    var frequencyDays: Int

    /// 前回完了日（nilの場合は未完了）
    var lastCompletedDate: Date?

    /// 次回予定日
    var nextDueDate: Date

    /// 作成日時
    var createdAt: Date

    /// 更新日時
    var updatedAt: Date

    /// 初期化
    /// - Parameters:
    ///   - name: 家事の名称
    ///   - frequencyDays: 頻度（日数）
    ///   - nextDueDate: 次回予定日（指定しない場合は今日）
    init(
        name: String,
        frequencyDays: Int,
        nextDueDate: Date? = nil
    ) {
        self.name = name
        self.frequencyDays = frequencyDays
        self.lastCompletedDate = nil
        self.nextDueDate = nextDueDate ?? Calendar.current.startOfDay(for: Date())
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// 予定日までの残り日数
    /// - 正の値: まだ余裕がある
    /// - 0: 今日が予定日
    /// - 負の値: 期限を過ぎている
    var daysUntilDue: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDay = calendar.startOfDay(for: nextDueDate)
        let components = calendar.dateComponents([.day], from: today, to: dueDay)
        return components.day ?? 0
    }

    /// 期限切れかどうか
    var isOverdue: Bool {
        daysUntilDue < 0
    }

    /// 今日が予定日かどうか
    var isDueToday: Bool {
        daysUntilDue == 0
    }

    /// ステータス表示用
    var statusDescription: String {
        let days = daysUntilDue
        if days < 0 {
            return "\(abs(days))日超過"
        } else if days == 0 {
            return "今日"
        } else {
            return "あと\(days)日"
        }
    }
}

// MARK: - Identifiable
extension ChoreItem: Identifiable {}
