//
//  ChoreItemTests.swift
//  FlexChoreTests
//
//  Created by FlexChore Team on 2026/02/15.
//

import Testing
import Foundation
@testable import FlexChore

struct ChoreItemTests {

    private let calendar = Calendar.current

    // MARK: - Helper

    private func date(daysFromNow days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: Date()))!
    }

    // MARK: - Initialization Tests

    @Test("初期化: デフォルト値で作成")
    func init_withDefaults() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)

        #expect(chore.name == "掃除")
        #expect(chore.frequencyDays == 7)
        #expect(chore.lastCompletedDate == nil)
        #expect(calendar.isDate(chore.nextDueDate, inSameDayAs: Date()))
    }

    @Test("初期化: 次回予定日を指定")
    func init_withNextDueDate() {
        let futureDate = date(daysFromNow: 5)
        let chore = ChoreItem(name: "洗濯", frequencyDays: 3, nextDueDate: futureDate)

        #expect(calendar.isDate(chore.nextDueDate, inSameDayAs: futureDate))
    }

    // MARK: - daysUntilDue Tests

    @Test("残り日数: 今日が予定日")
    func daysUntilDue_today() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: 0))
        #expect(chore.daysUntilDue == 0)
    }

    @Test("残り日数: 3日後が予定日")
    func daysUntilDue_future() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: 3))
        #expect(chore.daysUntilDue == 3)
    }

    @Test("残り日数: 2日前が予定日（期限切れ）")
    func daysUntilDue_past() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: -2))
        #expect(chore.daysUntilDue == -2)
    }

    // MARK: - Status Tests

    @Test("ステータス: 期限切れ判定")
    func isOverdue_whenPastDue() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: -1))
        #expect(chore.isOverdue == true)
    }

    @Test("ステータス: 今日は期限切れではない")
    func isOverdue_todayIsFalse() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: 0))
        #expect(chore.isOverdue == false)
    }

    @Test("ステータス: 今日が予定日")
    func isDueToday_whenToday() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: 0))
        #expect(chore.isDueToday == true)
    }

    @Test("ステータス: 明日は今日ではない")
    func isDueToday_tomorrowIsFalse() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: 1))
        #expect(chore.isDueToday == false)
    }

    // MARK: - statusDescription Tests

    @Test("ステータス表示: 今日")
    func statusDescription_today() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: 0))
        #expect(chore.statusDescription == "今日")
    }

    @Test("ステータス表示: あと3日")
    func statusDescription_upcoming() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: 3))
        #expect(chore.statusDescription == "あと3日")
    }

    @Test("ステータス表示: 2日超過")
    func statusDescription_overdue() {
        let chore = ChoreItem(name: "テスト", frequencyDays: 7, nextDueDate: date(daysFromNow: -2))
        #expect(chore.statusDescription == "2日超過")
    }
}
