//
//  MainTabView.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import SwiftUI

/// メインのタブナビゲーション
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ChoreListView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(0)

            CalendarView()
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(AppTheme.primaryMint)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: ChoreItem.self, inMemory: true)
}
