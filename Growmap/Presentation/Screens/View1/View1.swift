//
//  GoalInputView.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import SwiftUI

struct GoalInputView: View {
    @StateObject private var viewModel: GoalInputViewModel
    @State private var navigateToPeriodSelection = false

    init(viewModel: GoalInputViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Text("目標を入力してください")
                    .font(.title2)
                    .fontWeight(.medium)

                TextEditor(text: $viewModel.goalText)
                    .frame(height: 200)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                Spacer()

                NavigationLink(destination: PeriodSelectionView(viewModel: PeriodSelectionViewModel(useCase: viewModel.useCase)), isActive: $navigateToPeriodSelection) {
                    EmptyView()
                }

                Button(action: {
                    viewModel.saveGoal()
                    navigateToPeriodSelection = true
                }) {
                    Text("次へ")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryBrown)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Color.appBackground.ignoresSafeArea())
        }
        .navigationTitle("目標入力")
        .navigationBarTitleDisplayMode(.inline)
    }
}
