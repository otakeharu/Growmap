//
//  ElementInputViewModel.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import Combine

class ElementInputViewModel: ObservableObject {
    @Published var elements: [String] = Array(repeating: "", count: 8)

    let useCase: GoalUseCase

    init(useCase: GoalUseCase) {
        self.useCase = useCase
        loadElements()
    }

    private func loadElements() {
        let savedElements = useCase.getElements()
        for (index, element) in savedElements.enumerated() where index < 8 {
            elements[index] = element.text
        }
    }

    func saveElements(updateProgress: Bool = false) {
        var savedElements = useCase.getElements()

        // 既存のElementsが8個未満の場合は新規作成
        while savedElements.count < 8 {
            savedElements.append(Element(text: "", actions: Array(repeating: Action(), count: 4)))
        }

        // textだけを更新、actionsは保持
        for (index, text) in elements.enumerated() where index < 8 {
            savedElements[index].text = text
        }

        useCase.saveElements(savedElements)

        // 「次へ」ボタンを押したときだけ進捗を更新
        if updateProgress {
            useCase.updateEditProgress(.elementsEntered)
        }
    }
}
