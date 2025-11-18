//
//  PeriodSelectionViewModel.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import Combine

class PeriodSelectionViewModel: ObservableObject {
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()

    let useCase: GoalUseCase

    init(useCase: GoalUseCase) {
        self.useCase = useCase
        loadDates()
    }

    private func loadDates() {
        if let goal = useCase.getGoal() {
            startDate = goal.startDate
            endDate = goal.targetDate
        }
    }

    func saveDates() {
        var goal = useCase.getGoal() ?? Goal()
        goal.startDate = startDate
        goal.targetDate = endDate
        useCase.saveGoal(goal)
    }

    // 終了日が開始日より前にならないようにバリデーション
    func validateDates() -> Bool {
        return endDate >= startDate
    }
}
