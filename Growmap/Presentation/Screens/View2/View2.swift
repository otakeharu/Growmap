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
        VStack(spacing: 20) {
            Spacer()

            Text("目標達成日を選択してください")
                .font(.title2)
                .fontWeight(.medium)

            DatePicker(
                "",
                selection: $viewModel.selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Date.jpLocale)
            .environment(\.calendar, Date.jpCalendar)

            Spacer()

            NavigationLink(destination: ElementInputView(viewModel: ElementInputViewModel(useCase: viewModel.useCase)), isActive: $navigateToElementInput) {
                EmptyView()
            }

            Button(action: {
                viewModel.saveTargetDate()
                navigateToElementInput = true
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
        .navigationTitle("期間選択")
        .navigationBarTitleDisplayMode(.inline)
    }
}
