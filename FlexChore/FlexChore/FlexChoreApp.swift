//
//  FlexChoreApp.swift
//  FlexChore
//
//  Created by Tsutsui.Yasuyuki on 2026/02/15.
//

import SwiftUI
import SwiftData

@main
struct FlexChoreApp: App {
    let sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([
            ChoreItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .task {
                    await initializeApp()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    /// アプリ起動時の初期化処理
    @MainActor
    private func initializeApp() async {
        let initializer = AppInitializer(modelContainer: sharedModelContainer)
        await initializer.initialize()
    }
}
