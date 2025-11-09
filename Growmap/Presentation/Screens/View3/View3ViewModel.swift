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

    func saveElements() {
        let elementObjects = elements.map { text in
            Element(text: text, actions: Array(repeating: Action(), count: 4))
        }
        useCase.saveElements(elementObjects)
    }
}
