//
//  CalendarView.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import SwiftUI
import SwiftData

/// カレンダー形式で家事予定を表示するView
struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChoreItem.nextDueDate) private var chores: [ChoreItem]

    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var selectedChore: ChoreItem?
    @State private var viewModel = ChoreListViewModel()

    private let calendar = Calendar.current
    private let scheduler = ChoreScheduler()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 月のナビゲーション（ミントヘッダー）
                monthNavigationHeader

                // 曜日ヘッダー
                weekdayHeader

                // カレンダーグリッド
                calendarGrid

                Divider()

                // 選択日の家事一覧
                selectedDateChoreList
            }
            .background(AppTheme.backgroundMint)
            .navigationTitle("カレンダー")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if os(iOS)
            .toolbarBackground(AppTheme.primaryMint, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
            .sheet(item: $selectedChore) { chore in
                EditChoreView(chore: chore)
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    // MARK: - Month Navigation

    private var monthNavigationHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(AppTheme.accentTeal)
            }

            Spacer()

            Text(currentMonth, format: .dateTime.year().month())
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(AppTheme.accentTeal)
            }
        }
        .padding()
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.veryShortWeekdaySymbols
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let days = daysInMonth()

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 64)
                }
            }
        }
        .padding(.horizontal)
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let choresOnDay = chores(for: date)

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isToday ? .white : .primary)
                    .frame(width: 28, height: 28)
                    .background {
                        if isToday {
                            Circle().fill(AppTheme.primaryMint)
                        } else if isSelected {
                            Circle().stroke(AppTheme.primaryMint, lineWidth: 2)
                        }
                    }

                // 家事名バッジ
                VStack(spacing: 1) {
                    ForEach(choresOnDay.prefix(2)) { chore in
                        Text(chore.name)
                            .font(.system(size: 8))
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 1)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(choreColor(for: chore, on: date).opacity(0.3))
                            )
                    }
                    if choresOnDay.count > 2 {
                        Text("+\(choresOnDay.count - 2)")
                            .font(.system(size: 7))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 24)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 64)
    }

    // MARK: - Selected Date Chore List

    private var selectedDateChoreList: some View {
        let choresOnDay = chores(for: selectedDate)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(selectedDate, format: .dateTime.month().day().weekday())
                    .font(.headline)

                Spacer()

                Text("\(choresOnDay.count)件")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            if choresOnDay.isEmpty {
                Text("この日の予定はありません")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(choresOnDay) { chore in
                        HStack {
                            Circle()
                                .fill(choreColor(for: chore, on: selectedDate))
                                .frame(width: 10, height: 10)

                            Text(chore.name)
                                .font(.body)

                            Spacer()

                            Text("\(chore.frequencyDays)日ごと")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedChore = chore
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Helper Methods

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else {
            return []
        }

        let startOfCalendar = monthFirstWeek.start
        var days: [Date?] = []

        for dayOffset in 0..<42 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfCalendar) else {
                continue
            }

            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                days.append(date)
            } else if days.isEmpty || days.last != nil {
                days.append(nil)
            }
        }

        while days.last == nil && !days.isEmpty {
            days.removeLast()
        }

        return days
    }

    private func chores(for date: Date) -> [ChoreItem] {
        chores.filter { calendar.isDate($0.nextDueDate, inSameDayAs: date) }
    }

    private func choreColor(for chore: ChoreItem, on date: Date) -> Color {
        let today = calendar.startOfDay(for: Date())
        let choreDate = calendar.startOfDay(for: date)

        if choreDate < today {
            return Color(hex: "FF6B6B")
        } else if calendar.isDateInToday(date) {
            return AppTheme.primaryMint
        } else {
            return Color(hex: "51CF66")
        }
    }

    private func moveMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: ChoreItem.self, inMemory: true)
}
