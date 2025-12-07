//
//  PeriodSelectionView.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import SwiftUI

struct PeriodSelectionView: View {
    @StateObject private var viewModel: PeriodSelectionViewModel
    @State private var navigateToElementInput = false

    // 🎨 デザイン調整用の設定（ここを変更すると全体が変わります）
    private let titleFontSize: CGFloat = 20           // タイトルのサイズ（デフォルト: 20 = .title2相当）
    private let labelFontSize: CGFloat = 17           // ラベルのサイズ（デフォルト: 17 = .headline相当）
    private let periodTextFontSize: CGFloat = 15      // 期間表示のサイズ（デフォルト: 15 = .subheadline相当）
    private let topSpacing: CGFloat = 30              // VStackの間隔
    private let sectionSpacing: CGFloat = 20          // セクション間の間隔
    private let labelSpacing: CGFloat = 10            // ラベルと要素の間隔
    private let datePickerPadding: CGFloat = 16       // DatePickerの内側余白
    private let datePickerCornerRadius: CGFloat = 12  // DatePickerの角丸

    init(viewModel: PeriodSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: topSpacing) {
            Spacer()

            Text("計画の期間を選択してください")
                .font(.system(size: titleFontSize))
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)

            VStack(spacing: sectionSpacing) {
                // 開始日
                VStack(spacing: labelSpacing) {
                    Text("開始日")
                        .font(.system(size: labelFontSize))
                        .foregroundColor(.primaryBrown)

                    DatePicker(
                        "",
                        selection: $viewModel.startDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .environment(\.locale, Date.jpLocale)
                    .environment(\.calendar, Date.jpCalendar)
                    .padding(datePickerPadding)
                    .background(Color.white)
                    .cornerRadius(datePickerCornerRadius)
                }

                // 終了日
                VStack(spacing: labelSpacing) {
                    Text("終了日（目標達成日）")
                        .font(.system(size: labelFontSize))
                        .foregroundColor(.primaryBrown)

                    DatePicker(
                        "",
                        selection: $viewModel.endDate,
                        in: viewModel.startDate...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .environment(\.locale, Date.jpLocale)
                    .environment(\.calendar, Date.jpCalendar)
                    .padding(datePickerPadding)
                    .background(Color.white)
                    .cornerRadius(datePickerCornerRadius)
                }

                // 期間表示
                if viewModel.validateDates() {
                    let days = Calendar.current.dateComponents([.day], from: viewModel.startDate, to: viewModel.endDate).day ?? 0
                    Text("期間: \(days + 1)日間")
                        .font(.system(size: periodTextFontSize))
                        .foregroundColor(.secondaryBrown)
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            NavigationLink(destination: ElementInputView(viewModel: ElementInputViewModel(useCase: viewModel.useCase)), isActive: $navigateToElementInput) {
                EmptyView()
            }

            Button(action: {
                if viewModel.validateDates() {
                    viewModel.saveDates()
                    navigateToElementInput = true
                }
            }) {
                Text("次へ")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.validateDates() ? Color.primaryBrown : Color.gray)
                    .cornerRadius(20)
            }
            .disabled(!viewModel.validateDates())
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("期間選択")
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
