//
//  AppInitializer.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import Foundation
import SwiftData
import os

/// アプリ起動時の初期化処理を担当
final class AppInitializer {

    private let notificationService: NotificationService
    private let modelContainer: ModelContainer
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "FlexChore", category: "AppInitializer")

    init(
        notificationService: NotificationService = .shared,
        modelContainer: ModelContainer
    ) {
        self.notificationService = notificationService
        self.modelContainer = modelContainer
    }

    /// アプリ起動時の初期化処理を実行
    @MainActor
    func initialize() async {
        // 1. 通知の許可をリクエスト
        await requestNotificationPermissionIfNeeded()

        // 2. 全ての通知を再スケジュール
        await rescheduleAllNotifications()

        // 3. データ整合性チェック（将来的な拡張用）
        await validateDataIntegrity()
    }

    // MARK: - Private Methods

    /// 通知の許可をリクエスト（未設定の場合のみ）
    private func requestNotificationPermissionIfNeeded() async {
        let status = await notificationService.getAuthorizationStatus()

        switch status {
        case .notDetermined:
            // まだ許可を求めていない場合はリクエスト
            await notificationService.requestAuthorization()
        case .authorized, .provisional, .ephemeral:
            // 許可済み
            break
        case .denied:
            // ユーザーが拒否している場合は何もしない
            break
        @unknown default:
            break
        }
    }

    /// 全ての家事の通知を再スケジュール
    @MainActor
    private func rescheduleAllNotifications() async {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<ChoreItem>()

        do {
            let chores = try context.fetch(descriptor)
            await notificationService.rescheduleAllReminders(for: chores)
        } catch {
            logger.error("家事データの取得に失敗: \(error.localizedDescription)")
        }
    }

    /// データ整合性チェック
    @MainActor
    private func validateDataIntegrity() async {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<ChoreItem>()

        do {
            let chores = try context.fetch(descriptor)

            for chore in chores {
                // 頻度が0以下の場合は1に修正
                if chore.frequencyDays <= 0 {
                    chore.frequencyDays = 1
                    chore.updatedAt = Date()
                }

                // 名前が空の場合はデフォルト名を設定
                if chore.name.trimmingCharacters(in: .whitespaces).isEmpty {
                    chore.name = "名称未設定"
                    chore.updatedAt = Date()
                }
            }
        } catch {
            logger.error("データ整合性チェックに失敗: \(error.localizedDescription)")
        }
    }
}
