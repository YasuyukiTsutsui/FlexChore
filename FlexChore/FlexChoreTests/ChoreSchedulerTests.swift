//
//  ChoreSchedulerTests.swift
//  FlexChoreTests
//
//  Created by FlexChore Team on 2026/02/15.
//

import Testing
import Foundation
@testable import FlexChore

struct ChoreSchedulerTests {

    private let calendar = Calendar.current
    private let scheduler = ChoreScheduler()

    // MARK: - Helper

    /// 指定した日数後の日付を取得
    private func date(daysFromNow days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: Date()))!
    }

    /// 指定した年月日の日付を取得
    private func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)!
    }

    // MARK: - calculateNextDueDate Tests

    @Test("次回予定日の計算: 基準日 + 頻度日数")
    func calculateNextDueDate_addsFrequencyDays() {
        let baseDate = date(year: 2026, month: 2, day: 15)
        let result = scheduler.calculateNextDueDate(from: baseDate, frequencyDays: 7)

        let expected = date(year: 2026, month: 2, day: 22)
        #expect(calendar.isDate(result, inSameDayAs: expected))
    }

    @Test("次回予定日の計算: 月をまたぐ場合")
    func calculateNextDueDate_crossesMonthBoundary() {
        let baseDate = date(year: 2026, month: 2, day: 25)
        let result = scheduler.calculateNextDueDate(from: baseDate, frequencyDays: 7)

        let expected = date(year: 2026, month: 3, day: 4)
        #expect(calendar.isDate(result, inSameDayAs: expected))
    }

    @Test("次回予定日の計算: 年をまたぐ場合")
    func calculateNextDueDate_crossesYearBoundary() {
        let baseDate = date(year: 2026, month: 12, day: 28)
        let result = scheduler.calculateNextDueDate(from: baseDate, frequencyDays: 7)

        let expected = date(year: 2027, month: 1, day: 4)
        #expect(calendar.isDate(result, inSameDayAs: expected))
    }

    @Test("次回予定日の計算: 頻度1日（毎日）")
    func calculateNextDueDate_dailyFrequency() {
        let baseDate = date(year: 2026, month: 2, day: 15)
        let result = scheduler.calculateNextDueDate(from: baseDate, frequencyDays: 1)

        let expected = date(year: 2026, month: 2, day: 16)
        #expect(calendar.isDate(result, inSameDayAs: expected))
    }

    // MARK: - markAsCompleted Tests

    @Test("完了処理: 次回予定日が完了日+頻度に更新される")
    func markAsCompleted_updatesNextDueDate() {
        let chore = ChoreItem(name: "テスト家事", frequencyDays: 7)
        let completionDate = date(year: 2026, month: 2, day: 15)

        scheduler.markAsCompleted(chore, on: completionDate)

        let expectedNextDue = date(year: 2026, month: 2, day: 22)
        #expect(calendar.isDate(chore.nextDueDate, inSameDayAs: expectedNextDue))
    }

    @Test("完了処理: 前回完了日が更新される")
    func markAsCompleted_updatesLastCompletedDate() {
        let chore = ChoreItem(name: "テスト家事", frequencyDays: 7)
        let completionDate = date(year: 2026, month: 2, day: 15)

        scheduler.markAsCompleted(chore, on: completionDate)

        #expect(chore.lastCompletedDate != nil)
        #expect(calendar.isDate(chore.lastCompletedDate!, inSameDayAs: completionDate))
    }

    @Test("完了処理: 更新日時が設定される")
    func markAsCompleted_updatesTimestamp() {
        let chore = ChoreItem(name: "テスト家事", frequencyDays: 7)
        let originalUpdatedAt = chore.updatedAt

        // 少し待ってから完了処理
        scheduler.markAsCompleted(chore)

        #expect(chore.updatedAt >= originalUpdatedAt)
    }

    // MARK: - reschedule Tests

    @Test("リスケジュール: 予定日が新しい日付に更新される")
    func reschedule_updatesNextDueDate() {
        let chore = ChoreItem(name: "テスト家事", frequencyDays: 7)
        let newDate = date(year: 2026, month: 3, day: 1)

        scheduler.reschedule(chore, to: newDate)

        #expect(calendar.isDate(chore.nextDueDate, inSameDayAs: newDate))
    }

    @Test("リスケジュール後の完了: 新しいサイクルが適用される")
    func reschedule_thenComplete_usesNewCycle() {
        let chore = ChoreItem(name: "テスト家事", frequencyDays: 7)

        // 3/1にリスケジュール
        let rescheduledDate = date(year: 2026, month: 3, day: 1)
        scheduler.reschedule(chore, to: rescheduledDate)

        // 3/1に完了
        scheduler.markAsCompleted(chore, on: rescheduledDate)

        // 次回予定日は3/8になるはず
        let expectedNextDue = date(year: 2026, month: 3, day: 8)
        #expect(calendar.isDate(chore.nextDueDate, inSameDayAs: expectedNextDue))
    }

    // MARK: - adjustDueDate Tests

    @Test("日付調整: 後ろ倒し")
    func adjustDueDate_postpone() {
        let chore = ChoreItem(
            name: "テスト家事",
            frequencyDays: 7,
            nextDueDate: date(year: 2026, month: 2, day: 15)
        )

        scheduler.adjustDueDate(chore, byDays: 3)

        let expected = date(year: 2026, month: 2, day: 18)
        #expect(calendar.isDate(chore.nextDueDate, inSameDayAs: expected))
    }

    @Test("日付調整: 前倒し")
    func adjustDueDate_bringForward() {
        let chore = ChoreItem(
            name: "テスト家事",
            frequencyDays: 7,
            nextDueDate: date(year: 2026, month: 2, day: 15)
        )

        scheduler.adjustDueDate(chore, byDays: -2)

        let expected = date(year: 2026, month: 2, day: 13)
        #expect(calendar.isDate(chore.nextDueDate, inSameDayAs: expected))
    }

    // MARK: - Filter Tests

    @Test("今日の家事フィルタ")
    func todayChores_filtersCorrectly() {
        let today = calendar.startOfDay(for: Date())
        let chore1 = ChoreItem(name: "今日の家事", frequencyDays: 7, nextDueDate: today)
        let chore2 = ChoreItem(name: "明日の家事", frequencyDays: 7, nextDueDate: date(daysFromNow: 1))
        let chore3 = ChoreItem(name: "昨日の家事", frequencyDays: 7, nextDueDate: date(daysFromNow: -1))

        let result = scheduler.todayChores(from: [chore1, chore2, chore3])

        #expect(result.count == 1)
        #expect(result.first?.name == "今日の家事")
    }

    @Test("期限切れの家事フィルタ")
    func overdueChores_filtersCorrectly() {
        let chore1 = ChoreItem(name: "今日の家事", frequencyDays: 7, nextDueDate: date(daysFromNow: 0))
        let chore2 = ChoreItem(name: "明日の家事", frequencyDays: 7, nextDueDate: date(daysFromNow: 1))
        let chore3 = ChoreItem(name: "昨日の家事", frequencyDays: 7, nextDueDate: date(daysFromNow: -1))
        let chore4 = ChoreItem(name: "3日前の家事", frequencyDays: 7, nextDueDate: date(daysFromNow: -3))

        let result = scheduler.overdueChores(from: [chore1, chore2, chore3, chore4])

        #expect(result.count == 2)
        #expect(result.contains { $0.name == "昨日の家事" })
        #expect(result.contains { $0.name == "3日前の家事" })
    }
}
