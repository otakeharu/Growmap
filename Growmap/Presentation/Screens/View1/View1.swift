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
    @FocusState private var isTextEditorFocused: Bool

    init(viewModel: GoalInputViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            // 上部のラベル
            Text("目標を入力してください")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.top, 20)

            Spacer()

            // TextEditorとプレースホルダーを重ねる（中央配置）
            ZStack(alignment: .top) {
                // プレースホルダー
                if viewModel.goalText.isEmpty {
                    Text("目標を入力")
                        .foregroundColor(Color.gray.opacity(0.5))
                        .font(.largeTitle)
                        .padding(.top, 8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // TextEditor（枠線なし、中央揃え）
                TextEditor(text: $viewModel.goalText)
                    .frame(height: 200)
                    .font(.largeTitle)
                    .padding(0)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .multilineTextAlignment(.center)
                    .focused($isTextEditorFocused)
            }
            .padding(.horizontal, 20)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextEditorFocused = true
                }
            }

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
        .navigationTitle("目標入力")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    NotificationCenter.default.post(name: .navigateToHome, object: nil)
                }) {
                    Image(systemName: "house.fill")
                        .foregroundColor(.primaryBrown)
                }
            }
        }
    }
}
