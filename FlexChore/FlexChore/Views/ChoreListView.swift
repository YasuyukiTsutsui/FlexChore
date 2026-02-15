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
        ZStack(alignment: .bottom) {
            // メインコンテンツ
            ScrollView {
                VStack(spacing: 0) {
                    headerView

                    if chores.isEmpty {
                        emptyStateView
                    } else {
                        choreCards
                    }
                }
                .padding(.bottom, 100)
            }
            .background(AppTheme.backgroundMint)

            // FAB
            #if os(iOS)
            floatingActionButton
            #endif
        }
        #if os(macOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        #endif
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

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("今日")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("|")
                    .opacity(0.7)
                Text(Date(), format: .dateTime.month().day())
                    .font(.title3)
                Spacer()
            }
            .foregroundStyle(.white)

            if !chores.isEmpty {
                HStack {
                    Text(progressText)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(AppTheme.primaryMint)
    }

    private var progressText: String {
        let actionable = overdueChores.count + todayChores.count
        let total = chores.count
        let completed = total - actionable
        let percentage = total > 0 ? Int((Double(completed) / Double(total)) * 100) : 0
        return "残り\(actionable)種類です (\(percentage)%完了)"
    }

    // MARK: - Chore Cards

    private var choreCards: some View {
        VStack(spacing: AppTheme.cardSpacing) {
            ForEach(sortedChores) { chore in
                ChoreRowView(chore: chore) {
                    completeChore(chore)
                } onPostpone: {
                    postponeChore(chore)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedChore = chore
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var sortedChores: [ChoreItem] {
        chores.sorted { lhs, rhs in
            if lhs.isOverdue && !rhs.isOverdue { return true }
            if !lhs.isOverdue && rhs.isOverdue { return false }
            if lhs.isDueToday && !rhs.isDueToday { return true }
            if !lhs.isDueToday && rhs.isDueToday { return false }
            return lhs.nextDueDate < rhs.nextDueDate
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "house")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.primaryMint)
            Text("家事がありません")
                .font(.title3)
                .fontWeight(.medium)
            Text("下の + ボタンから家事を追加してください")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    // MARK: - FAB

    #if os(iOS)
    private var floatingActionButton: some View {
        Button {
            showingAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: AppTheme.fabSize, height: AppTheme.fabSize)
                .background(
                    Circle()
                        .fill(AppTheme.primaryMint)
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                )
        }
        .padding(.bottom, AppTheme.fabBottomPadding)
    }
    #endif

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

    private func postponeChore(_ chore: ChoreItem) {
        withAnimation {
            viewModel.adjustChoreDate(chore, byDays: 1)
        }
    }
}

#Preview {
    ChoreListView()
        .modelContainer(for: ChoreItem.self, inMemory: true)
}
