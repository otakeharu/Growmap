//
//  Action.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

struct Action: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String

    init(id: UUID = UUID(), text: String = "") {
        self.id = id
        self.text = text
    }
}
