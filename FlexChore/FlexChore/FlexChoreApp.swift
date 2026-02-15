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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ChoreItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ChoreListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
