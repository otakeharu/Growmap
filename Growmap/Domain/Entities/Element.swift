//
//  Element.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

struct Element: Identifiable, Codable {
    let id: UUID
    var text: String
    var actions: [Action]

    init(id: UUID = UUID(), text: String = "", actions: [Action] = []) {
        self.id = id
        self.text = text
        self.actions = actions
    }
}
