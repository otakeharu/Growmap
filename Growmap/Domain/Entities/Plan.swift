//
//  Plan.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

struct Plan: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var goal: Goal
    var elements: [Element]
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), name: String, goal: Goal, elements: [Element] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.goal = goal
        self.elements = elements
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
