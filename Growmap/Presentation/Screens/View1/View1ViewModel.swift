//
//  GoalInputViewModel.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import Combine

class GoalInputViewModel: ObservableObject {
    @Published var goalText: String = ""

    let useCase: GoalUseCase

    init(useCase: GoalUseCase) {
        self.useCase = useCase
        loadGoal()
    }

    private func loadGoal() {
        if let goal = useCase.getGoal() {
            goalText = goal.text
        }
    }

    func saveGoal() {
        let goal = Goal(text: goalText, targetDate: Date())
        useCase.saveGoal(goal)
        useCase.updateEditProgress(.goalEntered)
    }
}
