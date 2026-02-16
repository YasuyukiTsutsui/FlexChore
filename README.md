# FlexChore

**「やった日」から次の予定が決まる、柔軟な家事管理アプリ**

FlexChore は、家事の実行サイクルを「頻度（日数）」で管理するアプリです。
従来のカレンダーアプリやリマインダーとは異なり、**完了した日を起点に次回の予定が自動で再計算される**ため、生活リズムに合わせて無理なく家事を回すことができます。

<!-- スクリーンショットを追加する場合はここに配置 -->
<!-- ![Screenshot](docs/screenshots/home.png) -->

## 既存ツールとの違い

| 比較項目 | カレンダーアプリ / リマインダー | FlexChore |
|:---|:---|:---|
| スケジュール方式 | 固定の曜日・日付に繰り返し設定 | **頻度（N日ごと）** で柔軟に管理 |
| 予定日のずれへの対応 | 手動でリスケジュールが必要 | **完了日から自動で次回を再計算** |
| 延期 | 通知を閉じるか、手動で日付変更 | **ワンタップで +1日延期** |
| 期限超過の可視化 | 通知が消えると見失いやすい | **超過日数を表示 & 色分けで一目瞭然** |
| 家事に特化した表示 | 汎用的なリスト表示 | **優先度順ソート（超過 > 今日 > 今後）** |

### FlexChore が解決する課題

- **「毎週月曜に掃除」と決めても、できなかった週はズレていく** — FlexChore なら完了日ベースで次回が決まるので、サイクルが自然に調整されます
- **「あと何日で次の掃除？」が分からない** — 残り日数・超過日数がカード上に常時表示されます
- **今日やれなかった家事を明日に回すのが面倒** — +1日ボタンでワンタップ延期できます

## 主な機能

### 家事の周期管理
頻度プリセット（毎日 / 2日ごと / 3日ごと / 週1回 / 2週間ごと / 月1回）から選択、または1〜365日の範囲で自由に設定できます。

### 完了ベースの自動スケジューリング
家事を完了すると、**完了日 + 設定頻度** で次回予定日が自動計算されます。
固定曜日に縛られず、実際の生活ペースに合ったサイクルが維持されます。

### 柔軟なリスケジュール
- ワンタップで **+1日延期**
- 編集画面から **「今日」「明日」「-1日」「+1日」** のクイックアクション
- DatePicker で任意の日付に変更

### ステータス別カード表示
家事カードの背景色で状態が一目で分かります。

| 状態 | 背景色 | 説明 |
|:---|:---|:---|
| 期限超過 | ピーチ | 予定日を過ぎた家事（超過日数を表示） |
| 今日 | ミントブルー | 今日が予定日の家事 |
| 今後 | ホワイト | 予定日がまだ先の家事（残り日数を表示） |

### カレンダービュー
月間カレンダーで家事の予定を俯瞰できます。日付ごとに家事がバッジ表示され、選択した日の家事一覧も確認できます。

### リマインダー通知
予定日の朝にローカル通知でリマインドします。通知の ON/OFF と通知時刻は設定画面から変更できます。

## 対応プラットフォーム

| プラットフォーム | 最小バージョン |
|:---|:---|
| iOS | 18.1+ |
| iPadOS | 18.1+ |
| macOS | 14.0+ |
| visionOS | 対応 |

## 技術スタック

| レイヤー | 技術 |
|:---|:---|
| UI | SwiftUI |
| データ永続化 | SwiftData |
| 状態管理 | @Observable（MVVM） |
| 通知 | UserNotifications |
| ログ | os.Logger |

## アーキテクチャ

MVVM パターンを採用し、各レイヤーの責務を明確に分離しています。

```
FlexChore/
├── App/                 # アプリ初期化・エントリーポイント
│   ├── FlexChoreApp.swift
│   └── AppInitializer.swift
├── Models/              # データモデル（SwiftData）
│   └── ChoreItem.swift
├── Views/               # SwiftUI ビュー
│   ├── MainTabView.swift
│   ├── ChoreListView.swift
│   ├── ChoreRowView.swift
│   ├── AddChoreView.swift
│   ├── EditChoreView.swift
│   ├── CalendarView.swift
│   └── SettingsView.swift
├── ViewModels/          # ビジネスロジック
│   ├── ChoreListViewModel.swift
│   ├── AddChoreViewModel.swift
│   └── EditChoreViewModel.swift
├── Services/            # ドメインサービス
│   ├── ChoreScheduler.swift    # 日付計算・スケジュール管理
│   └── NotificationService.swift # ローカル通知管理
└── Theme/               # デザイントークン
    └── AppTheme.swift
```

## データモデル

```swift
@Model
final class ChoreItem {
    var name: String              // 家事の名称
    var frequencyDays: Int        // 頻度（日数）
    var lastCompletedDate: Date?  // 前回完了日
    var nextDueDate: Date         // 次回予定日
    var createdAt: Date           // 作成日時
    var updatedAt: Date           // 更新日時
    var stableIdentifier: String  // 通知用の安定識別子
}
```

## ビルド方法

### 必要環境
- Xcode 16.0+
- iOS 18.1+ / macOS 14.0+

### 手順
1. リポジトリをクローン
   ```bash
   git clone https://github.com/YasuyukiTsutsui/FlexChore.git
   ```
2. `FlexChore/FlexChore.xcodeproj` を Xcode で開く
3. ターゲットデバイスを選択してビルド・実行

## ライセンス

MIT License
