//
//  SettingsView.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/15.
//

import SwiftUI
import UserNotifications

/// 設定画面
struct SettingsView: View {
    @AppStorage("notificationEnabled") private var notificationEnabled = true
    @AppStorage("notificationHour") private var notificationHour = 9
    @AppStorage("notificationMinute") private var notificationMinute = 0

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingNotificationAlert = false

    private let notificationService = NotificationService.shared

    var body: some View {
        NavigationStack {
            Form {
                // 通知設定
                notificationSection

                // アプリ情報
                aboutSection
            }
            .navigationTitle("設定")
            .task {
                await checkNotificationStatus()
            }
            .alert("通知を許可してください", isPresented: $showingNotificationAlert) {
                Button("設定を開く") {
                    openSettings()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("リマインダー通知を受け取るには、設定アプリで通知を許可してください。")
            }
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        Section {
            Toggle("リマインダー通知", isOn: $notificationEnabled)
                .onChange(of: notificationEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await requestNotificationPermission()
                        }
                    }
                }

            if notificationEnabled {
                HStack {
                    Text("通知時刻")

                    Spacer()

                    Picker("時", selection: $notificationHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text("\(hour)時").tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()

                    Picker("分", selection: $notificationMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text(String(format: "%02d分", minute)).tag(minute)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                // 通知許可状態
                HStack {
                    Text("通知許可")
                    Spacer()
                    Text(notificationStatusText)
                        .foregroundStyle(notificationStatusColor)
                }
            }
        } header: {
            Text("通知")
        } footer: {
            Text("予定日の朝に家事のリマインダーを通知します")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            LabeledContent("バージョン") {
                Text(appVersion)
            }

            LabeledContent("ビルド") {
                Text(buildNumber)
            }
        } header: {
            Text("アプリ情報")
        }
    }

    // MARK: - Helper Properties

    private var notificationStatusText: String {
        switch notificationStatus {
        case .authorized:
            return "許可済み"
        case .denied:
            return "拒否"
        case .provisional:
            return "仮許可"
        case .ephemeral:
            return "一時的"
        case .notDetermined:
            return "未設定"
        @unknown default:
            return "不明"
        }
    }

    private var notificationStatusColor: Color {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .secondary
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Helper Methods

    private func checkNotificationStatus() async {
        notificationStatus = await notificationService.getAuthorizationStatus()
    }

    private func requestNotificationPermission() async {
        let granted = await notificationService.requestAuthorization()
        await checkNotificationStatus()

        if !granted && notificationStatus == .denied {
            showingNotificationAlert = true
            notificationEnabled = false
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
}
