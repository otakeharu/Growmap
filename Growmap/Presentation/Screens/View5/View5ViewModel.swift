//
//  GanttChartViewModel.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import Combine

class GanttChartViewModel: ObservableObject {
    private let reminderManager = ReminderManager()
    @Published var days: [Date] = []
    @Published var elements: [Element] = []
    @Published var currentMonth: String = ""
    @Published var targetDate: Date = Date()
    @Published var scrollOffset: CGFloat = 0
    @Published var goalText: String = ""

    let useCase: GoalUseCase
    private let calendar = Date.jpCalendar

    init(useCase: GoalUseCase) {
        self.useCase = useCase
        loadData()
    }

    private func loadData() {
        elements = useCase.getElements()

        if let goal = useCase.getGoal() {
            goalText = goal.text
            targetDate = goal.targetDate
            let startDate = calendar.startOfDay(for: goal.startDate)
            let endDate = calendar.startOfDay(for: targetDate)

            days = generateDays(from: startDate, to: endDate)
        } else {
            // Goalが存在しない場合は今日から表示（後方互換性のため）
            let today = calendar.startOfDay(for: Date())
            let endDate = calendar.startOfDay(for: targetDate)

            days = generateDays(from: today, to: endDate)
        }

        updateCurrentMonth()
    }

    func reloadData() {
        loadData()
    }

    private func generateDays(from startDate: Date, to endDate: Date) -> [Date] {
        var days: [Date] = []
        var currentDate = startDate

        while currentDate <= endDate {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return days
    }

    func updateCurrentMonth() {
        if let firstVisibleDay = days.first {
            currentMonth = DateFormatter.monthYearFormatter.string(from: firstVisibleDay)
        }
    }

    func toggleDayState(elementIndex: Int, actionIndex: Int, date: Date) {
        useCase.toggleDayState(elementIndex: elementIndex + 1, actionIndex: actionIndex + 1, date: date)
    }

    func getDayState(elementIndex: Int, actionIndex: Int, date: Date) -> Bool {
        useCase.getDayState(elementIndex: elementIndex + 1, actionIndex: actionIndex + 1, date: date)
    }

    func isTargetDate(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: targetDate)
    }

    var rowCount: Int {
        elements.count * 5  // 要素行 + 4つの行動行
    }

    func isElementRow(for rowIndex: Int) -> Bool {
        rowIndex % 5 == 0
    }

    func getRowTitle(for rowIndex: Int) -> String {
        let groupIndex = rowIndex / 5
        let positionInGroup = rowIndex % 5

        guard groupIndex < elements.count else { return "" }
        let element = elements[groupIndex]

        if positionInGroup == 0 {
            // 要素行
            return element.text.isEmpty ? "要素\(groupIndex + 1)" : element.text
        } else {
            // 行動行
            let actionIndex = positionInGroup - 1
            guard actionIndex < element.actions.count else { return "" }
            return element.actions[actionIndex].text
        }
    }

    func getElementIndex(for rowIndex: Int) -> Int {
        rowIndex / 5
    }

    func getActionIndex(for rowIndex: Int) -> Int {
        let positionInGroup = rowIndex % 5
        return positionInGroup - 1
    }

    // 要素の全ての行動のうち、少なくとも1つがONかチェック
    func isAnyActionOnForElement(elementIndex: Int, date: Date) -> Bool {
        guard elementIndex < elements.count else { return false }

        for actionIndex in 0..<4 {
            if getDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date) {
                return true
            }
        }
        return false
    }

    // 要素の全ての行動を一括でトグル
    func toggleAllActionsForElement(elementIndex: Int, date: Date) {
        guard elementIndex < elements.count else { return }

        // 現在の状態を確認（少なくとも1つONなら全てOFFに、全てOFFなら全てONに）
        let isAnyOn = isAnyActionOnForElement(elementIndex: elementIndex, date: date)

        for actionIndex in 0..<4 {
            let currentState = getDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)

            if isAnyOn {
                // 少なくとも1つONなら全てOFFにする
                if currentState {
                    toggleDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
                }
            } else {
                // 全てOFFなら全てONにする
                if !currentState {
                    toggleDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
                }
            }
        }
    }

    // リマインダーにエクスポート
    func exportToReminders() async -> (success: Int, total: Int) {
        let reminderData = useCase.getReminderData()
        return await reminderManager.exportToReminders(reminderData: reminderData)
    }
}
