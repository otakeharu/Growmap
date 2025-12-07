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

    // 🎨 デザイン調整用の設定（ここを変更すると全体が変わります）
    private let inputFontSize: CGFloat = 35        // 入力テキストのサイズ（デフォルト: 34 = .largeTitle相当）
    private let labelTopPadding: CGFloat = 50// ラベルの上余白
    private let labelBottomPadding: CGFloat = 110
  // ラベルと入力欄の間隔
    private let inputAreaHeight: CGFloat = 200     // 入力エリアの高さ

    init(viewModel: GoalInputViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 上部のラベル
            Text("目標を入力してください")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.top, labelTopPadding)
                .padding(.bottom, labelBottomPadding)

            // TextEditorとプレースホルダーを重ねる（中央配置）
            ZStack(alignment: .top) {
                // プレースホルダー
                if viewModel.goalText.isEmpty {
                    Text("目標を入力")
                        .foregroundColor(Color.gray.opacity(0.5))
                        .font(.system(size: inputFontSize))
                        .padding(.top, 8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // TextEditor（枠線なし、中央揃え）
                TextEditor(text: $viewModel.goalText)
                    .frame(height: inputAreaHeight)
                    .font(.system(size: inputFontSize))
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
