//
//  EditChoreViewModelTests.swift
//  FlexChoreTests
//
//  Created by FlexChore Team on 2026/02/15.
//

import Testing
import Foundation
@testable import FlexChore

struct EditChoreViewModelTests {

    private let calendar = Calendar.current

    // MARK: - Helper

    private func date(daysFromNow days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: Date()))!
    }

    // MARK: - Initialization Tests

    @Test("初期化: 家事の値がコピーされる")
    func init_copiesChoreValues() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7, nextDueDate: date(daysFromNow: 3))
        let viewModel = EditChoreViewModel(chore: chore)

        #expect(viewModel.name == "掃除")
        #expect(viewModel.frequencyDays == 7)
        #expect(calendar.isDate(viewModel.nextDueDate, inSameDayAs: date(daysFromNow: 3)))
    }

    // MARK: - hasChanges Tests

    @Test("変更検出: 初期状態では変更なし")
    func hasChanges_initiallyFalse() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)
        let viewModel = EditChoreViewModel(chore: chore)

        #expect(viewModel.hasChanges == false)
    }

    @Test("変更検出: 名前を変更すると変更あり")
    func hasChanges_nameChanged() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.name = "掃除機がけ"

        #expect(viewModel.hasChanges == true)
    }

    @Test("変更検出: 頻度を変更すると変更あり")
    func hasChanges_frequencyChanged() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.frequencyDays = 14

        #expect(viewModel.hasChanges == true)
    }

    @Test("変更検出: 予定日を変更すると変更あり")
    func hasChanges_dueDateChanged() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7, nextDueDate: date(daysFromNow: 3))
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.nextDueDate = date(daysFromNow: 5)

        #expect(viewModel.hasChanges == true)
    }

    // MARK: - Validation Tests

    @Test("バリデーション: 有効な入力")
    func isValid_withValidInput() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)
        let viewModel = EditChoreViewModel(chore: chore)

        #expect(viewModel.isValid == true)
        #expect(viewModel.validationErrors.isEmpty)
    }

    @Test("バリデーション: 空の名前は無効")
    func isValid_emptyNameInvalid() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.name = "   "

        #expect(viewModel.isValid == false)
        #expect(viewModel.validationErrors.contains("家事の名前を入力してください"))
    }

    @Test("バリデーション: 頻度0は無効")
    func isValid_zeroFrequencyInvalid() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.frequencyDays = 0

        #expect(viewModel.isValid == false)
        #expect(viewModel.validationErrors.contains("頻度は1日以上に設定してください"))
    }

    // MARK: - canSave Tests

    @Test("保存可能: 変更があり有効な入力の場合")
    func canSave_withChangesAndValid() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.name = "掃除機がけ"

        #expect(viewModel.canSave == true)
    }

    @Test("保存不可: 変更がない場合")
    func canSave_noChanges() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)
        let viewModel = EditChoreViewModel(chore: chore)

        #expect(viewModel.canSave == false)
    }

    @Test("保存不可: 無効な入力の場合")
    func canSave_invalidInput() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7)
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.name = ""

        #expect(viewModel.canSave == false)
    }

    // MARK: - revert Tests

    @Test("元に戻す: 変更が破棄される")
    func revert_discardsChanges() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7, nextDueDate: date(daysFromNow: 3))
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.name = "洗濯"
        viewModel.frequencyDays = 14
        viewModel.nextDueDate = date(daysFromNow: 10)

        viewModel.revert()

        #expect(viewModel.name == "掃除")
        #expect(viewModel.frequencyDays == 7)
        #expect(calendar.isDate(viewModel.nextDueDate, inSameDayAs: date(daysFromNow: 3)))
        #expect(viewModel.hasChanges == false)
    }

    // MARK: - Quick Actions Tests

    @Test("クイックアクション: 1日後ろ倒し")
    func postponeOneDay_addsOneDay() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7, nextDueDate: date(daysFromNow: 3))
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.postponeOneDay()

        #expect(calendar.isDate(viewModel.nextDueDate, inSameDayAs: date(daysFromNow: 4)))
    }

    @Test("クイックアクション: 1日前倒し")
    func bringForwardOneDay_subtractsOneDay() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7, nextDueDate: date(daysFromNow: 3))
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.bringForwardOneDay()

        #expect(calendar.isDate(viewModel.nextDueDate, inSameDayAs: date(daysFromNow: 2)))
    }

    @Test("クイックアクション: 今日に設定")
    func setDueToday_setsToToday() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7, nextDueDate: date(daysFromNow: 5))
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.setDueToday()

        #expect(calendar.isDate(viewModel.nextDueDate, inSameDayAs: date(daysFromNow: 0)))
    }

    @Test("クイックアクション: 明日に設定")
    func setDueTomorrow_setsToTomorrow() {
        let chore = ChoreItem(name: "掃除", frequencyDays: 7, nextDueDate: date(daysFromNow: 5))
        let viewModel = EditChoreViewModel(chore: chore)

        viewModel.setDueTomorrow()

        #expect(calendar.isDate(viewModel.nextDueDate, inSameDayAs: date(daysFromNow: 1)))
    }
}
