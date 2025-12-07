//
//  GrowmapApp.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import SwiftUI

@main
struct GrowmapApp: App {
    var body: some Scene {
        WindowGroup {
            let planRepository = PlanRepository()
            let planUseCase = PlanUseCase(planRepository: planRepository)
            PlanListView(viewModel: PlanListViewModel(planUseCase: planUseCase))
        }
    }
}
