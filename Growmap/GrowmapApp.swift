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
            let dataSource = UserDefaultsDataSource()
            let repository = GoalRepository(dataSource: dataSource)
            let useCase = GoalUseCase(repository: repository)
            GoalInputView(viewModel: GoalInputViewModel(useCase: useCase))
        }
    }
}
