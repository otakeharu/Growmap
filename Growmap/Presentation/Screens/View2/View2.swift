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

    init(viewModel: PeriodSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("計画の期間を選択してください")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)

            VStack(spacing: 20) {
                // 開始日
                VStack(spacing: 10) {
                    Text("開始日")
                        .font(.headline)
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
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }

                // 終了日
                VStack(spacing: 10) {
                    Text("終了日（目標達成日）")
                        .font(.headline)
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
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }

                // 期間表示
                if viewModel.validateDates() {
                    let days = Calendar.current.dateComponents([.day], from: viewModel.startDate, to: viewModel.endDate).day ?? 0
                    Text("期間: \(days + 1)日間")
                        .font(.subheadline)
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
    }
}
