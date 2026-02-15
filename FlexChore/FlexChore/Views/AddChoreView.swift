//
//  AddChoreView.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import SwiftUI
import SwiftData

/// 新しい家事を追加するシート
struct AddChoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var frequencyDays = 7
    @State private var nextDueDate = Date()

    // 頻度のプリセット
    private let frequencyPresets = [
        (label: "毎日", days: 1),
        (label: "2日ごと", days: 2),
        (label: "3日ごと", days: 3),
        (label: "週1回", days: 7),
        (label: "2週間ごと", days: 14),
        (label: "月1回", days: 30),
    ]

    var body: some View {
        NavigationStack {
            Form {
                // 家事名
                Section {
                    TextField("家事の名前", text: $name)
                } header: {
                    Text("名前")
                }

                // 頻度
                Section {
                    Picker("頻度", selection: $frequencyDays) {
                        ForEach(frequencyPresets, id: \.days) { preset in
                            Text(preset.label).tag(preset.days)
                        }
                    }
                    .pickerStyle(.segmented)

                    Stepper("\(frequencyDays)日ごと", value: $frequencyDays, in: 1...365)
                } header: {
                    Text("頻度")
                } footer: {
                    Text("この家事を何日おきに行うか設定します")
                }

                // 次回予定日
                Section {
                    DatePicker(
                        "次回予定日",
                        selection: $nextDueDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                } header: {
                    Text("開始日")
                } footer: {
                    Text("最初にこの家事を行う予定日を選択してください")
                }
            }
            .navigationTitle("家事を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        addChore()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addChore() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let newChore = ChoreItem(
            name: trimmedName,
            frequencyDays: frequencyDays,
            nextDueDate: nextDueDate
        )

        modelContext.insert(newChore)
        dismiss()
    }
}

#Preview {
    AddChoreView()
        .modelContainer(for: ChoreItem.self, inMemory: true)
}
