//
//  GoalUseCase.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

class GoalUseCase {
    private let repository: GoalRepositoryProtocol

    init(repository: GoalRepositoryProtocol) {
        self.repository = repository
    }

    func saveGoal(_ goal: Goal) {
        repository.saveGoal(goal)
    }

    func getGoal() -> Goal? {
        repository.getGoal()
    }

    func saveElements(_ elements: [Element]) {
        repository.saveElements(elements)
    }

    func getElements() -> [Element] {
        repository.getElements()
    }

    func saveDayState(_ state: DayState) {
        repository.saveDayState(state)
    }

    func getDayState(elementIndex: Int, actionIndex: Int, date: Date) -> Bool {
        repository.getDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
    }

    func toggleDayState(elementIndex: Int, actionIndex: Int, date: Date) {
        let currentState = getDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
        let newState = DayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date, isOn: !currentState)
        saveDayState(newState)
    }
}
