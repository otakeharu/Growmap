//
//  GoalRepositoryProtocol.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

protocol GoalRepositoryProtocol {
    func saveGoal(_ goal: Goal)
    func getGoal() -> Goal?

    func saveElements(_ elements: [Element])
    func getElements() -> [Element]

    func saveDayState(_ state: DayState)
    func getDayState(elementIndex: Int, actionIndex: Int, date: Date) -> Bool
    func getAllDayStates() -> [DayState]
}
