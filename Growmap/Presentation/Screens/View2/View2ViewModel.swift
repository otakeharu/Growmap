//
//  PeriodSelectionViewModel.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import Combine

class PeriodSelectionViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()

    let useCase: GoalUseCase

    init(useCase: GoalUseCase) {
        self.useCase = useCase
        loadTargetDate()
    }

    private func loadTargetDate() {
        if let goal = useCase.getGoal() {
            selectedDate = goal.targetDate
        }
    }

    func saveTargetDate() {
        var goal = useCase.getGoal() ?? Goal()
        goal.targetDate = selectedDate
        useCase.saveGoal(goal)
    }
}
