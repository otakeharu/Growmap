//
//  GanttChartViewModel.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import Combine

class GanttChartViewModel: ObservableObject {
    @Published var days: [Date] = []
    @Published var elements: [Element] = []
    @Published var currentMonth: String = ""
    @Published var targetDate: Date = Date()
    @Published var scrollOffset: CGFloat = 0

    let useCase: GoalUseCase
    private let calendar = Date.jpCalendar

    init(useCase: GoalUseCase) {
        self.useCase = useCase
        loadData()
    }

    private func loadData() {
        elements = useCase.getElements()

        if let goal = useCase.getGoal() {
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
        elements.count * 4
    }

    func getRowTitle(for rowIndex: Int) -> String {
        let elementIndex = rowIndex / 4
        let actionIndex = rowIndex % 4

        guard elementIndex < elements.count else { return "" }

        let element = elements[elementIndex]
        guard actionIndex < element.actions.count else { return "" }

        return element.actions[actionIndex].text
    }

    func getElementIndex(for rowIndex: Int) -> Int {
        rowIndex / 4
    }

    func getActionIndex(for rowIndex: Int) -> Int {
        rowIndex % 4
    }
}
