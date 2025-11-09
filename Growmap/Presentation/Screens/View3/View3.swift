//
//  ElementInputView.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import SwiftUI

struct ElementInputView: View {
    @StateObject private var viewModel: ElementInputViewModel
    @State private var navigateToActionInput = false
    @State private var goalText: String = ""

    init(viewModel: ElementInputViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("目標達成に必要な要素を考えよう")
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)

            // 3x3 Grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<9, id: \.self) { index in
                    if index == 4 {
                        // Center cell - Display goal
                        Text(goalText)
                            .font(.system(size: 13))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .frame(width: 110, height: 110)
                            .background(Color(red: 211/255, green: 197/255, blue: 178/255))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .padding(0)
                    } else {
                        // Other cells - TextEditor
                        let elementIndex = index < 4 ? index : index - 1
                        TextEditor(text: $viewModel.elements[elementIndex])
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .frame(width: 110, height: 110)
                            .background(Color(red: 211/255, green: 197/255, blue: 178/255))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .padding(0)
                    }
                }
            }
            .frame(width: 330, height: 330)
            .padding(.horizontal, 20)

            Spacer()

            NavigationLink(destination: ActionInputView(viewModel: ActionInputViewModel(useCase: viewModel.useCase)), isActive: $navigateToActionInput) {
                EmptyView()
            }

            Button(action: {
                viewModel.saveElements()
                navigateToActionInput = true
            }) {
                Text("次へ")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryBrown)
                    .cornerRadius(20)
            }
            .padding(.horizontal, 60)
            .padding(.bottom, 40)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("要素")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let goal = viewModel.useCase.getGoal() {
                goalText = goal.text
            }
        }
    }
}
