//
//  Goal.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

struct Goal: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var startDate: Date      // 計画開始日
    var targetDate: Date     // 目標達成日

    init(id: UUID = UUID(), text: String = "", startDate: Date = Date(), targetDate: Date = Date()) {
        self.id = id
        self.text = text
        self.startDate = startDate
        self.targetDate = targetDate
    }

    // 古いデータとの互換性のためのカスタムデコーダー
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        targetDate = try container.decode(Date.self, forKey: .targetDate)

        // startDateが存在しない場合はtargetDateから逆算してデフォルト値を設定
        if let decodedStartDate = try? container.decode(Date.self, forKey: .startDate) {
            startDate = decodedStartDate
        } else {
            // 古いデータの場合、targetDateの1ヶ月前をデフォルトとする
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: targetDate) ?? Date()
        }
    }
}
