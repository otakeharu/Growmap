//
//  DayState.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

struct DayState: Codable {
    let elementIndex: Int
    let actionIndex: Int
    let date: Date
    var isOn: Bool

    init(elementIndex: Int, actionIndex: Int, date: Date, isOn: Bool = false) {
        self.elementIndex = elementIndex
        self.actionIndex = actionIndex
        self.date = date
        self.isOn = isOn
    }
}
