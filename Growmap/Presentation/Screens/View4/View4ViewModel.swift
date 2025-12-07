//
//  ActionInputViewModel.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import Combine

class ActionInputViewModel: ObservableObject {
    @Published var currentElementIndex: Int = 0
    @Published var actions: [[String]] = Array(repeating: Array(repeating: "", count: 4), count: 8)
    @Published var elementTexts: [String] = Array(repeating: "", count: 8)

    let useCase: GoalUseCase

    init(useCase: GoalUseCase) {
        self.useCase = useCase
        loadElements()
    }

    private func loadElements() {
        let savedElements = useCase.getElements()
        for (elementIndex, element) in savedElements.enumerated() where elementIndex < 8 {
            elementTexts[elementIndex] = element.text
            for (actionIndex, action) in element.actions.enumerated() where actionIndex < 4 {
                actions[elementIndex][actionIndex] = action.text
            }
        }
    }

    func reloadElements() {
        loadElements()
    }

    func saveCurrentPage() {
        saveAllActions()
    }

    func saveAllActions(updateProgress: Bool = false) {
        var elements = useCase.getElements()
        for (elementIndex, _) in elements.enumerated() where elementIndex < 8 {
            for actionIndex in 0..<4 {
                elements[elementIndex].actions[actionIndex].text = actions[elementIndex][actionIndex]
            }
        }
        useCase.saveElements(elements)

        // 「完了」ボタンを押したときだけ進捗を更新
        if updateProgress {
            useCase.updateEditProgress(.actionsEntered)
        }
    }

    func completeAndSave() {
        saveAllActions(updateProgress: true)
    }

    func nextPage() {
        saveCurrentPage()
        if currentElementIndex < 7 {
            currentElementIndex += 1
        }
    }

    func previousPage() {
        saveCurrentPage()
        if currentElementIndex > 0 {
            currentElementIndex -= 1
        }
    }

    var currentElementText: String {
        elementTexts[currentElementIndex]
    }

    var currentActions: [String] {
        actions[currentElementIndex]
    }

    func updateAction(at index: Int, with text: String) {
        actions[currentElementIndex][index] = text
    }
}
