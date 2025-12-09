//
//  PlanListView.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import SwiftUI

struct PlanListView: View {
    @StateObject private var viewModel: PlanListViewModel
    @State private var selectedPlanId: UUID?
    @State private var navigateToView1 = false
    @State private var navigateToView2 = false
    @State private var navigateToView3 = false
    @State private var navigateToView4 = false
    @State private var navigateToView5 = false

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
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("HOME")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let newPlan = viewModel.createNewPlanWithTemporaryName()
                        selectedPlanId = newPlan.id
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            navigateToView1 = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.primaryBrown)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .navigateToHome)) { _ in
                resetNavigation()
            }
        }
    }

    private func resetNavigation() {
        navigateToView1 = false
        navigateToView2 = false
        navigateToView3 = false
        navigateToView4 = false
        navigateToView5 = false
        selectedPlanId = nil
        viewModel.loadPlans()
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
                let newPlan = viewModel.createNewPlanWithTemporaryName()
                selectedPlanId = newPlan.id
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigateToView1 = true
                }
            }) {
                Text("新しい目標を設定")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.primaryBrown)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    private var planListView: some View {
        ZStack {
            List {
                ForEach(viewModel.plans) { plan in
                    Button(action: {
                        handlePlanSelection(plan)
                    }) {
                        PlanRow(plan: plan)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowBackground(Color.appBackground)
                }
                .onDelete(perform: viewModel.deletePlan)
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)

            // 各画面へのNavigationLink（非表示）
            if let planId = selectedPlanId, let plan = viewModel.plans.first(where: { $0.id == planId }) {
                NavigationLink(destination: createView1(for: plan), isActive: $navigateToView1) { EmptyView() }.hidden()
                NavigationLink(destination: createView2(for: plan), isActive: $navigateToView2) { EmptyView() }.hidden()
                NavigationLink(destination: createView3(for: plan), isActive: $navigateToView3) { EmptyView() }.hidden()
                NavigationLink(destination: createView4(for: plan), isActive: $navigateToView4) { EmptyView() }.hidden()
                NavigationLink(destination: createView5(for: plan), isActive: $navigateToView5) { EmptyView() }.hidden()
            }
        }
    }

    private func handlePlanSelection(_ plan: Plan) {
        viewModel.selectPlan(plan)

        // まず全てのナビゲーションをリセット
        navigateToView1 = false
        navigateToView2 = false
        navigateToView3 = false
        navigateToView4 = false
        navigateToView5 = false

        selectedPlanId = plan.id

        // 進捗に応じて適切な画面に遷移
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch plan.editProgress {
            case .notStarted:
                self.navigateToView1 = true
            case .goalEntered:
                self.navigateToView2 = true
            case .periodSelected:
                self.navigateToView3 = true
            case .elementsEntered:
                self.navigateToView4 = true
            case .actionsEntered, .completed:
                self.navigateToView5 = true
            }
        }
    }

    private func createUseCase(for plan: Plan) -> GoalUseCase {
        let dataSource = UserDefaultsDataSource()
        let repository = GoalRepository(dataSource: dataSource)
        let useCase = GoalUseCase(repository: repository, planUseCase: viewModel.planUseCase)
        useCase.setPlanId(plan.id.uuidString)
        return useCase
    }

    private func createView1(for plan: Plan) -> some View {
        GoalInputView(viewModel: GoalInputViewModel(useCase: createUseCase(for: plan)))
    }

    private func createView2(for plan: Plan) -> some View {
        PeriodSelectionView(viewModel: PeriodSelectionViewModel(useCase: createUseCase(for: plan)))
    }

    private func createView3(for plan: Plan) -> some View {
        ElementInputView(viewModel: ElementInputViewModel(useCase: createUseCase(for: plan)))
    }

    private func createView4(for plan: Plan) -> some View {
        ActionInputView(viewModel: ActionInputViewModel(useCase: createUseCase(for: plan)))
    }

    private func createView5(for plan: Plan) -> some View {
        GanttChartView(viewModel: GanttChartViewModel(useCase: createUseCase(for: plan)))
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
