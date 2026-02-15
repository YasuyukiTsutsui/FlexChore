//
//  ChoreListView.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import SwiftUI
import SwiftData

/// 家事一覧を表示するメインView
struct ChoreListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChoreItem.nextDueDate) private var chores: [ChoreItem]

    @State private var showingAddSheet = false
    @State private var selectedChore: ChoreItem?
    @State private var viewModel = ChoreListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if chores.isEmpty {
                    emptyStateView
                } else {
                    choreList
                }
            }
            .navigationTitle("FlexChore")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddChoreView()
            }
            .sheet(item: $selectedChore) { chore in
                EditChoreView(chore: chore)
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("家事がありません", systemImage: "house")
        } description: {
            Text("右上の + ボタンから家事を追加してください")
        }
    }

    private var choreList: some View {
        List {
            // 期限切れセクション
            if !overdueChores.isEmpty {
                Section {
                    ForEach(overdueChores) { chore in
                        choreRow(for: chore)
                    }
                    .onDelete { indexSet in
                        deleteChores(from: overdueChores, at: indexSet)
                    }
                } header: {
                    Label("期限切れ", systemImage: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                }
            }

            // 今日のセクション
            if !todayChores.isEmpty {
                Section {
                    ForEach(todayChores) { chore in
                        choreRow(for: chore)
                    }
                    .onDelete { indexSet in
                        deleteChores(from: todayChores, at: indexSet)
                    }
                } header: {
                    Label("今日", systemImage: "star.fill")
                        .foregroundStyle(.orange)
                }
            }

            // 今後の予定セクション
            if !upcomingChores.isEmpty {
                Section {
                    ForEach(upcomingChores) { chore in
                        choreRow(for: chore)
                    }
                    .onDelete { indexSet in
                        deleteChores(from: upcomingChores, at: indexSet)
                    }
                } header: {
                    Label("今後の予定", systemImage: "calendar")
                }
            }
        }
    }

    private func choreRow(for chore: ChoreItem) -> some View {
        ChoreRowView(chore: chore, onComplete: {
            completeChore(chore)
        })
        .contentShape(Rectangle())
        .onTapGesture {
            selectedChore = chore
        }
    }

    // MARK: - Computed Properties

    private var overdueChores: [ChoreItem] {
        chores.filter { $0.isOverdue }
    }

    private var todayChores: [ChoreItem] {
        chores.filter { $0.isDueToday }
    }

    private var upcomingChores: [ChoreItem] {
        chores.filter { $0.daysUntilDue > 0 }
    }

    // MARK: - Actions

    private func completeChore(_ chore: ChoreItem) {
        withAnimation {
            viewModel.completeChore(chore)
        }
    }

    private func deleteChores(from source: [ChoreItem], at offsets: IndexSet) {
        withAnimation {
            viewModel.deleteChores(from: source, at: offsets)
        }
    }
}

#Preview {
    ChoreListView()
        .modelContainer(for: ChoreItem.self, inMemory: true)
}
