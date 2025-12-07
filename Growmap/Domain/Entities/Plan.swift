//
//  Plan.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

enum EditProgress: String, Codable, Hashable {
    case notStarted         // まだ何も入力していない → View1へ
    case goalEntered        // 目標を入力済み → View2へ
    case periodSelected     // 期間選択済み → View3へ
    case elementsEntered    // 要素入力済み → View4へ
    case actionsEntered     // 行動入力済み → View5へ
    case completed          // 完了 → View5へ
}

struct Plan: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var goal: Goal
    var elements: [Element]
    var createdAt: Date
    var updatedAt: Date
    var editProgress: EditProgress

    init(id: UUID = UUID(), name: String, goal: Goal, elements: [Element] = [], createdAt: Date = Date(), updatedAt: Date = Date(), editProgress: EditProgress = .notStarted) {
        self.id = id
        self.name = name
        self.goal = goal
        self.elements = elements
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.editProgress = editProgress
    }
}
