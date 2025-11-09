//
//  ActionInputView.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import SwiftUI

struct ActionInputView: View {
    @StateObject private var viewModel: ActionInputViewModel
    @State private var navigateToGanttChart = false

    init(viewModel: ActionInputViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.currentElementText)
                .font(.title2)
                .fontWeight(.medium)
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            Spacer()

            VStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    HStack {
                        Text("\(index + 1).")
                            .font(.headline)
                            .frame(width: 30)

                        TextEditor(text: Binding(
                            get: { viewModel.currentActions[index] },
                            set: { viewModel.updateAction(at: index, with: $0) }
                        ))
                        .frame(height: 60)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }

            Spacer()

            HStack(spacing: 20) {
                if viewModel.currentElementIndex > 0 {
                    Button(action: {
                        viewModel.previousPage()
                    }) {
                        Text("戻る")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondaryBrown)
                            .cornerRadius(20)
                    }
                }

                if viewModel.currentElementIndex < 7 {
                    Button(action: {
                        viewModel.nextPage()
                    }) {
                        Text("次へ")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryBrown)
                            .cornerRadius(20)
                    }
                } else {
                    NavigationLink(destination: GanttChartView(viewModel: GanttChartViewModel(useCase: viewModel.useCase)), isActive: $navigateToGanttChart) {
                        EmptyView()
                    }

                    Button(action: {
                        viewModel.saveAllActions()
                        navigateToGanttChart = true
                    }) {
                        Text("完了")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryBrown)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("行動入力")
        .navigationBarTitleDisplayMode(.inline)
    }
}
