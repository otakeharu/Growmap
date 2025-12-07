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
    @State private var showAlert = false
    @State private var isCreatingPlan = false

    // 🎨 デザイン調整用の設定（ここを変更すると全体が変わります）
    private let elementTitleFontSize: CGFloat = 20    // 要素タイトルのサイズ（デフォルト: 20 = .title2相当）
    private let elementTitleTopPadding: CGFloat = 20  // 要素タイトルの上余白
    private let numberLabelFontSize: CGFloat = 17     // 番号ラベルのサイズ（デフォルト: 17 = .headline相当）
    private let numberLabelWidth: CGFloat = 30        // 番号ラベルの幅
    private let actionEditorHeight: CGFloat = 60      // 行動入力欄の高さ
    private let actionSpacing: CGFloat = 16           // 行動入力欄の間隔
    private let vStackSpacing: CGFloat = 20           // VStackの間隔

    init(viewModel: ActionInputViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: vStackSpacing) {
            Text(viewModel.currentElementText)
                .font(.system(size: elementTitleFontSize))
                .fontWeight(.medium)
                .padding(.top, elementTitleTopPadding)
                .padding(.horizontal, 20)
                .lineLimit(3)
                .minimumScaleFactor(0.7)

            Spacer()

            VStack(spacing: actionSpacing) {
                ForEach(0..<4, id: \.self) { index in
                    HStack {
                        Text("\(index + 1).")
                            .font(.system(size: numberLabelFontSize))
                            .frame(width: numberLabelWidth)

                        TextEditor(text: Binding(
                            get: { viewModel.currentActions[index] },
                            set: { viewModel.updateAction(at: index, with: $0) }
                        ))
                        .frame(height: actionEditorHeight)
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
                        viewModel.completeAndSave()
                        showAlert = true
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
        .onAppear {
            viewModel.reloadElements()
        }
        .alert("計画表を作成", isPresented: $showAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("作成する") {
                isCreatingPlan = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    navigateToGanttChart = true
                    isCreatingPlan = false
                }
            }
        } message: {
            Text("入力した内容で計画表を作成します")
        }
        .overlay {
            if isCreatingPlan {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)

                        Text("計画表を作成中...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(40)
                    .background(Color.primaryBrown.opacity(0.95))
                    .cornerRadius(20)
                }
            }
        }
    }
}
