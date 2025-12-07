import SwiftUI

struct ElementInputView: View {
    @StateObject private var viewModel: ElementInputViewModel
    @State private var navigateToActionInput = false
    @State private var goalText: String = ""
    @State private var showEditSheet = false
    @State private var editingIndex: Int?
    @State private var editingText: String = ""

    // デザイン値
    private let titleFontSize: CGFloat = 20
    private let titleTopPadding: CGFloat = 25
    private let goalCellFontSize: CGFloat = 15
    private let elementCellFontSize: CGFloat = 15
    private let cellSize: CGFloat = 110
    private let gridSize: CGFloat = 330
    private let gridSpacing: CGFloat = 0
    private let vStackSpacing: CGFloat = 20

    init(viewModel: ElementInputViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: vStackSpacing) {
            Text("目標達成に必要な要素を考えよう")
                .font(.system(size: titleFontSize))
                .fontWeight(.medium)
                .padding(.top, titleTopPadding)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)

            // 3×3 Grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: 3)

            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(0..<9, id: \.self) { index in
                    if index == 4 {
                        // ★ 中央セル（目標）：ベージュ背景
                        Text(goalText)
                            .font(.system(size: goalCellFontSize))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .frame(width: cellSize, height: cellSize)
                            .background(Color(red: 211/255, green: 197/255, blue: 178/255))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    } else {
                        // ★ 外側8マス：背景色 FDFBF6 にする
                        let elementIndex = index < 4 ? index : index - 1

                        Button(action: {
                            editingIndex = elementIndex
                            editingText = viewModel.elements[elementIndex]
                            showEditSheet = true
                        }) {
                            Text(viewModel.elements[elementIndex].isEmpty ? "" : viewModel.elements[elementIndex])
                                .font(.system(size: elementCellFontSize))
                                .multilineTextAlignment(.center)
                                .frame(width: cellSize, height: cellSize)
                                .background(Color(red: 253/255, green: 251/255, blue: 246/255))  // ← FDFBF6
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(width: gridSize, height: gridSize)
            .padding(.horizontal, 20)

            Spacer()

            NavigationLink(
                destination: ActionInputView(viewModel: ActionInputViewModel(useCase: viewModel.useCase)),
                isActive: $navigateToActionInput
            ) {
                EmptyView()
            }

            Button(action: {
                viewModel.saveElements(updateProgress: true)
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
            if let goal = viewModel.useCase.getGoal() {
                goalText = goal.text
            }
        }
        .overlay {
            if showEditSheet {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showEditSheet = false
                        }

                    ElementEditSheet(
                        text: $editingText,
                        onSave: {
                            if let index = editingIndex {
                                viewModel.elements[index] = editingText
                            }
                            showEditSheet = false
                        },
                        onCancel: {
                            showEditSheet = false
                        }
                    )
                    .frame(width: 350, height: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                    )
                    .shadow(radius: 20)
                }
            }
        }
    }
}


// 編集用シート（そのまま）
struct ElementEditSheet: View {
    @Binding var text: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)

            HStack {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("要素を入力")
                            .foregroundColor(Color.gray.opacity(0.5))
                            .font(.system(size: 16))
                    }

                    TextField("", text: $text)
                        .font(.system(size: 16))
                }
                .padding()
            }
            .frame(height: 50)
            .background(Color(red: 253/255, green: 251/255, blue: 246/255))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 20)

            Button(action: onSave) {
                Text("閉じる")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryBrown)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
        }
    }
}
