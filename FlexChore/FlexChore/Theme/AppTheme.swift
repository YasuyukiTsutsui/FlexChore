//
//  AppTheme.swift
//  FlexChore
//
//  Created by FlexChore Team on 2026/02/16.
//

import SwiftUI

/// アプリ全体のテーマ定義
enum AppTheme {

    // MARK: - Colors

    /// ヘッダー・アクセント用ミントグリーン
    static let primaryMint = Color(hex: "7FB8A4")

    /// 画面背景（薄いミント）
    static let backgroundMint = Color(hex: "F0F7F4")

    /// 期限切れカード背景（ピーチ）
    static let cardOverdue = Color(hex: "FDE8D0")

    /// 今日のカード背景（ミントブルー）
    static let cardToday = Color(hex: "D4EDEA")

    /// 今後のカード背景
    static let cardUpcoming = Color.white

    /// ボタン強調用ティール
    static let accentTeal = Color(hex: "5FA99B")

    // MARK: - Layout Constants

    static let cardCornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let cardSpacing: CGFloat = 12
    static let fabSize: CGFloat = 56
    static let fabBottomPadding: CGFloat = 24
    static let headerCornerRadius: CGFloat = 20
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
