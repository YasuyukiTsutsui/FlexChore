//
//  EditChoreView.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import SwiftUI

/// 家事の編集画面
struct EditChoreView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: EditChoreViewModel

    let chore: ChoreItem

    init(chore: ChoreItem) {
        self.chore = chore
        self._viewModel = State(initialValue: EditChoreViewModel(chore: chore))
    }

    var body: some View {
        NavigationStack {
            Form {
                // 名前セクション
                Section {
                    TextField("家事の名前", text: $viewModel.name)
                } header: {
                    Text("名前")
                }

                // 頻度セクション
                Section {
                    Picker("頻度", selection: $viewModel.frequencyDays) {
                        ForEach(AddChoreViewModel.frequencyPresets, id: \.days) { preset in
                            Text(preset.label).tag(preset.days)
                        }
                    }
                    .pickerStyle(.segmented)

                    Stepper("\(viewModel.frequencyDays)日ごと", value: $viewModel.frequencyDays, in: 1...365)
                } header: {
                    Text("頻度")
                }

                // 予定日セクション
                Section {
                    DatePicker(
                        "次回予定日",
                        selection: $viewModel.nextDueDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)

                    // クイックアクション
                    HStack(spacing: 12) {
                        quickActionButton("今日", action: viewModel.setDueToday)
                        quickActionButton("明日", action: viewModel.setDueTomorrow)
                        quickActionButton("-1日", action: viewModel.bringForwardOneDay)
                        quickActionButton("+1日", action: viewModel.postponeOneDay)
                    }
                    .frame(maxWidth: .infinity)
                } header: {
                    Text("次回予定日")
                }

                // 情報セクション
                Section {
                    if let lastCompleted = chore.lastCompletedDate {
                        LabeledContent("前回完了日") {
                            Text(lastCompleted, format: .dateTime.year().month().day())
                        }
                    }

                    LabeledContent("作成日") {
                        Text(chore.createdAt, format: .dateTime.year().month().day())
                    }
                } header: {
                    Text("情報")
                }
            }
            .navigationTitle("家事を編集")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .tint(AppTheme.primaryMint)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }

    // MARK: - Subviews

    private func quickActionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundStyle(AppTheme.accentTeal)
                .background(AppTheme.primaryMint.opacity(0.1))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EditChoreView(chore: ChoreItem(name: "掃除機がけ", frequencyDays: 7))
}
