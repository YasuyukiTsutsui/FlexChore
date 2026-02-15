//
//  AddChoreViewModel.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import Foundation
import SwiftData
import Observation

/// 家事追加画面のViewModel
@Observable
final class AddChoreViewModel {
    // MARK: - Form State

    var name: String = ""
    var frequencyDays: Int = 7
    var nextDueDate: Date = Calendar.current.startOfDay(for: Date())

    // MARK: - Validation

    /// 入力が有効かどうか
    var isValid: Bool {
        !trimmedName.isEmpty && frequencyDays > 0
    }

    /// トリミング済みの名前
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    /// バリデーションエラーメッセージ
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

    // MARK: - Frequency Presets

    /// 頻度のプリセット一覧
    static let frequencyPresets: [(label: String, days: Int)] = [
        ("毎日", 1),
        ("2日ごと", 2),
        ("3日ごと", 3),
        ("週1回", 7),
        ("2週間ごと", 14),
        ("月1回", 30),
    ]

    // MARK: - Actions

    /// 家事を作成して保存
    /// - Parameter modelContext: SwiftDataのModelContext
    /// - Returns: 作成成功したらtrue
    @discardableResult
    func save(to modelContext: ModelContext) -> Bool {
        guard isValid else { return false }

        let newChore = ChoreItem(
            name: trimmedName,
            frequencyDays: frequencyDays,
            nextDueDate: nextDueDate
        )

        modelContext.insert(newChore)
        return true
    }

    /// フォームをリセット
    func reset() {
        name = ""
        frequencyDays = 7
        nextDueDate = Calendar.current.startOfDay(for: Date())
    }
}
