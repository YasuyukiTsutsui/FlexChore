//
//  ChoreRowView.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import SwiftUI

/// 家事カードコンポーネント
struct ChoreRowView: View {
    let chore: ChoreItem
    let onComplete: () -> Void
    let onPostpone: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // 完了ボタン
            Button {
                onComplete()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.accentTeal)
            }
            .buttonStyle(.plain)

            // 家事情報
            VStack(alignment: .leading, spacing: 4) {
                Text(chore.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .foregroundStyle(.black)

                Text(chore.statusDescription)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }

            Spacer()

            // +1日ボタン
            Button {
                onPostpone()
            } label: {
                Text("+1日")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.accentTeal)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.accentTeal, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(AppTheme.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(cardBackgroundColor)
        )
    }

    private var cardBackgroundColor: Color {
        if chore.isOverdue {
            return AppTheme.cardOverdue
        } else if chore.isDueToday {
            return AppTheme.cardToday
        } else {
            return AppTheme.cardUpcoming
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.cardSpacing) {
        ChoreRowView(
            chore: ChoreItem(name: "掃除機がけ", frequencyDays: 3),
            onComplete: {},
            onPostpone: {}
        )
        ChoreRowView(
            chore: {
                let chore = ChoreItem(name: "洗濯", frequencyDays: 2)
                chore.nextDueDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
                return chore
            }(),
            onComplete: {},
            onPostpone: {}
        )
    }
    .padding()
    .background(AppTheme.backgroundMint)
}
