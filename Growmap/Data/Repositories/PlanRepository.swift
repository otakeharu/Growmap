//
//  PlanRepository.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

protocol PlanRepositoryProtocol {
    func savePlans(_ plans: [Plan])
    func getPlans() -> [Plan]
    func saveCurrentPlanId(_ id: UUID)
    func getCurrentPlanId() -> UUID?
}

class PlanRepository: PlanRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    private let plansKey = "plans"
    private let currentPlanIdKey = "currentPlanId"

    func savePlans(_ plans: [Plan]) {
        if let encoded = try? JSONEncoder().encode(plans) {
            userDefaults.set(encoded, forKey: plansKey)
        }
    }

    func getPlans() -> [Plan] {
        guard let data = userDefaults.data(forKey: plansKey),
              let plans = try? JSONDecoder().decode([Plan].self, from: data) else {
            return []
        }
        return plans
    }

    func saveCurrentPlanId(_ id: UUID) {
        userDefaults.set(id.uuidString, forKey: currentPlanIdKey)
    }

    func getCurrentPlanId() -> UUID? {
        guard let uuidString = userDefaults.string(forKey: currentPlanIdKey) else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }
}
