//
//  ChoreRowView.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import SwiftUI

/// 家事リストの各行を表示するView
struct ChoreRowView: View {
    let chore: ChoreItem
    let onComplete: () -> Void

    var body: some View {
        HStack {
            // 完了ボタン
            Button {
                onComplete()
            } label: {
                Image(systemName: "circle")
                    .font(.title2)
                    .foregroundStyle(statusColor)
            }
            .buttonStyle(.plain)

            // 家事情報
            VStack(alignment: .leading, spacing: 4) {
                Text(chore.name)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    // 頻度
                    Label("\(chore.frequencyDays)日ごと", systemImage: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // ステータス
                    Text(chore.statusDescription)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(statusColor)
                }
            }

            Spacer()

            // 予定日
            VStack(alignment: .trailing, spacing: 2) {
                Text(chore.nextDueDate, format: .dateTime.month().day())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(weekdayString)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Computed Properties

    private var statusColor: Color {
        if chore.isOverdue {
            return .red
        } else if chore.isDueToday {
            return .orange
        } else {
            return .green
        }
    }

    private var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: chore.nextDueDate)
    }
}

#Preview {
    List {
        ChoreRowView(
            chore: {
                let chore = ChoreItem(name: "掃除機がけ", frequencyDays: 3)
                return chore
            }(),
            onComplete: {}
        )

        ChoreRowView(
            chore: {
                let chore = ChoreItem(name: "洗濯", frequencyDays: 2)
                return chore
            }(),
            onComplete: {}
        )
    }
}
