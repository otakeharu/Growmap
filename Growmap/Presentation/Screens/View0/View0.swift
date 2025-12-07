//
//  PlanListView.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import SwiftUI

struct PlanListView: View {
    @StateObject private var viewModel: PlanListViewModel
    @State private var navigateToPlan: Plan?
    @State private var shouldDismissToRoot = false

    init(viewModel: PlanListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.plans.isEmpty {
                    emptyStateView
                } else {
                    planListView
                }
            }
            .navigationTitle("計画一覧")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showNewPlanAlert = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.primaryBrown)
                    }
                }
            }
            .alert("新しい計画", isPresented: $viewModel.showNewPlanAlert) {
                TextField("計画名", text: $viewModel.newPlanName)
                Button("キャンセル", role: .cancel) {
                    viewModel.newPlanName = ""
                }
                Button("作成") {
                    viewModel.createNewPlan()
                }
            } message: {
                Text("計画の名前を入力してください")
            }
            .onReceive(NotificationCenter.default.publisher(for: .navigateToHome)) { _ in
                navigateToPlan = nil
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("計画がありません")
                .font(.title2)
                .foregroundColor(.gray)

            Button(action: {
                viewModel.showNewPlanAlert = true
            }) {
                Text("新しい計画を作成")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBrown)
                    .cornerRadius(10)
            }
        }
    }

    private var planListView: some View {
        List {
            ForEach(viewModel.plans) { plan in
                NavigationLink(
                    destination: destinationView(for: plan),
                    tag: plan,
                    selection: $navigateToPlan
                ) {
                    PlanRow(plan: plan)
                }
                .onTapGesture {
                    viewModel.selectPlan(plan)
                    navigateToPlan = plan
                }
            }
            .onDelete(perform: viewModel.deletePlan)
        }
    }

    private func destinationView(for plan: Plan) -> some View {
        let dataSource = UserDefaultsDataSource()
        let repository = GoalRepository(dataSource: dataSource)
        let useCase = GoalUseCase(repository: repository)
        return GoalInputView(viewModel: GoalInputViewModel(useCase: useCase))
    }
}

struct PlanRow: View {
    let plan: Plan

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan.name)
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                Text(plan.goal.text.isEmpty ? "目標未設定" : plan.goal.text)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)

                Spacer()

                Text(DateFormatter.dateFormatter.string(from: plan.goal.targetDate))
                    .font(.caption)
                    .foregroundColor(.secondaryBrown)
            }
        }
        .padding(.vertical, 4)
    }
}

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
}
