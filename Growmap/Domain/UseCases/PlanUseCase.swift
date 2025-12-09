//
//  PlanUseCase.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

class PlanUseCase {
    private let planRepository: PlanRepositoryProtocol

    init(planRepository: PlanRepositoryProtocol) {
        self.planRepository = planRepository
    }

    func getPlans() -> [Plan] {
        planRepository.getPlans()
    }

    func savePlans(_ plans: [Plan]) {
        planRepository.savePlans(plans)
    }

    func createNewPlan(name: String) -> Plan {
        let goal = Goal(text: "", startDate: Date(), targetDate: Date())
        let elements = Array(repeating: Element(text: "", actions: Array(repeating: Action(), count: 4)), count: 8)
        return Plan(name: name, goal: goal, elements: elements)
    }

    func deletePlan(id: UUID) {
        var plans = getPlans()
        plans.removeAll { $0.id == id }
        savePlans(plans)
    }

    func updatePlan(_ plan: Plan) {
        var plans = getPlans()
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
            savePlans(plans)
        }
    }

    func getCurrentPlanId() -> UUID? {
        planRepository.getCurrentPlanId()
    }

    func setCurrentPlanId(_ id: UUID) {
        planRepository.saveCurrentPlanId(id)
    }

    func getCurrentPlan() -> Plan? {
        guard let currentId = getCurrentPlanId() else { return nil }
        return getPlans().first { $0.id == currentId }
    }

    func updateEditProgress(_ progress: EditProgress) {
        guard let currentId = getCurrentPlanId() else { return }
        var plans = getPlans()
        if let index = plans.firstIndex(where: { $0.id == currentId }) {
            plans[index].editProgress = progress
            plans[index].updatedAt = Date()
            savePlans(plans)
        }
    }

    func updateCurrentPlanName(_ name: String) {
        guard let currentId = getCurrentPlanId() else { return }
        var plans = getPlans()
        if let index = plans.firstIndex(where: { $0.id == currentId }) {
            plans[index].name = name
            plans[index].updatedAt = Date()
            savePlans(plans)
        }
    }
}
