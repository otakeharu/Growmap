//
//  CalendarEditViewModel.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import Combine

class CalendarEditViewModel: ObservableObject {
    @Published var selectedDates: Set<Date> = []

    let rowIndex: Int
    let elementIndex: Int
    let actionIndex: Int
    let startDate: Date
    let endDate: Date

    private let useCase: GoalUseCase
    private let calendar = Date.jpCalendar

    init(useCase: GoalUseCase, rowIndex: Int, elementIndex: Int, actionIndex: Int, startDate: Date, endDate: Date) {
        self.useCase = useCase
        self.rowIndex = rowIndex
        self.elementIndex = elementIndex
        self.actionIndex = actionIndex
        self.startDate = calendar.startOfDay(for: startDate)
        self.endDate = calendar.startOfDay(for: endDate)
        loadSelectedDates()
    }

    private func loadSelectedDates() {
        let days = generateDays(from: startDate, to: endDate)
        for day in days {
            if useCase.getDayState(elementIndex: elementIndex + 1, actionIndex: actionIndex + 1, date: day) {
                selectedDates.insert(day)
            }
        }
    }

    func toggleDate(_ date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)

        if selectedDates.contains(normalizedDate) {
            selectedDates.remove(normalizedDate)
            useCase.saveDayState(DayState(elementIndex: elementIndex + 1, actionIndex: actionIndex + 1, date: normalizedDate, isOn: false))
        } else {
            selectedDates.insert(normalizedDate)
            useCase.saveDayState(DayState(elementIndex: elementIndex + 1, actionIndex: actionIndex + 1, date: normalizedDate, isOn: true))
        }
    }

    func isDateSelected(_ date: Date) -> Bool {
        let normalizedDate = calendar.startOfDay(for: date)
        return selectedDates.contains(normalizedDate)
    }

    func isTargetDate(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: endDate)
    }

    private func generateDays(from start: Date, to end: Date) -> [Date] {
        var days: [Date] = []
        var current = start

        while current <= end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }

        return days
    }

    var monthsToDisplay: [Date] {
        var months: [Date] = []
        var currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate))!

        let endMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: endDate))!

        while currentMonth <= endMonth {
            months.append(currentMonth)
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
        }

        return months
    }
}
