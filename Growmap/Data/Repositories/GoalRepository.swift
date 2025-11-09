//
//  GoalRepository.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

class GoalRepository: GoalRepositoryProtocol {
    private let dataSource: UserDefaultsDataSource

    init(dataSource: UserDefaultsDataSource) {
        self.dataSource = dataSource
    }

    func saveGoal(_ goal: Goal) {
        dataSource.saveGoalText(goal.text)
        dataSource.saveTargetDate(goal.targetDate)
    }

    func getGoal() -> Goal? {
        guard let text = dataSource.getGoalText(),
              let targetDate = dataSource.getTargetDate() else {
            return nil
        }
        return Goal(text: text, targetDate: targetDate)
    }

    func saveElements(_ elements: [Element]) {
        for (elementIndex, element) in elements.enumerated() {
            let index = elementIndex + 1
            dataSource.saveElement(element.text, at: index)

            for (actionIndex, action) in element.actions.enumerated() {
                let aIndex = actionIndex + 1
                dataSource.saveAction(action.text, elementIndex: index, actionIndex: aIndex)
            }
        }
    }

    func getElements() -> [Element] {
        var elements: [Element] = []

        for elementIndex in 1...8 {
            let elementText = dataSource.getElement(at: elementIndex) ?? ""

            var actions: [Action] = []
            for actionIndex in 1...4 {
                let actionText = dataSource.getAction(elementIndex: elementIndex, actionIndex: actionIndex) ?? ""
                actions.append(Action(text: actionText))
            }

            elements.append(Element(text: elementText, actions: actions))
        }

        return elements
    }

    func saveDayState(_ state: DayState) {
        dataSource.saveDayState(
            elementIndex: state.elementIndex,
            actionIndex: state.actionIndex,
            date: state.date,
            isOn: state.isOn
        )
    }

    func getDayState(elementIndex: Int, actionIndex: Int, date: Date) -> Bool {
        dataSource.getDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
    }

    func getAllDayStates() -> [DayState] {
        return []
    }
}
