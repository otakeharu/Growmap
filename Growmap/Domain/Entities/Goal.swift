//
//  Goal.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    var text: String
    var targetDate: Date

    init(id: UUID = UUID(), text: String = "", targetDate: Date = Date()) {
        self.id = id
        self.text = text
        self.targetDate = targetDate
    }
}
