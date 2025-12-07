//
//  PlanListViewModel.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import Combine

class PlanListViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var showNewPlanAlert = false
    @Published var newPlanName = ""

    let planUseCase: PlanUseCase

    init(planUseCase: PlanUseCase) {
        self.planUseCase = planUseCase
        loadPlans()
    }

    func loadPlans() {
        plans = planUseCase.getPlans()
    }

    func createNewPlan() {
        guard !newPlanName.isEmpty else { return }
        let newPlan = planUseCase.createNewPlan(name: newPlanName)
        plans.append(newPlan)
        planUseCase.savePlans(plans)
        planUseCase.setCurrentPlanId(newPlan.id)
        newPlanName = ""
    }

    func deletePlan(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let plan = plans[index]
            planUseCase.deletePlan(id: plan.id)
        }
        loadPlans()
    }

    func selectPlan(_ plan: Plan) {
        planUseCase.setCurrentPlanId(plan.id)
    }
}
