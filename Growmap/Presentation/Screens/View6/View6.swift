//
//  CalendarEditView.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import SwiftUI

struct CalendarEditView: View {
    @StateObject private var viewModel: CalendarEditViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: CalendarEditViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.monthsToDisplay, id: \.self) { month in
                        MonthView(
                            month: month,
                            startDate: viewModel.startDate,
                            endDate: viewModel.endDate,
                            viewModel: viewModel
                        )
                    }
                }
                .padding()
            }
            .background(Color.lightBackground.ignoresSafeArea())
            .navigationTitle("カレンダー編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MonthView: View {
    let month: Date
    let startDate: Date
    let endDate: Date
    @ObservedObject var viewModel: CalendarEditViewModel

    private let calendar = Date.jpCalendar
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(spacing: 8) {
            Text(DateFormatter.monthYearFormatter.string(from: month))
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryBrown)
                .cornerRadius(8)

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.secondaryBrown.opacity(0.5))
                }

                ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                    Color.clear
                        .frame(height: 44)
                }

                ForEach(daysInMonth, id: \.self) { date in
                    DayButton(
                        date: date,
                        isSelected: viewModel.isDateSelected(date),
                        isTargetDate: viewModel.isTargetDate(date),
                        isInRange: isDateInRange(date)
                    ) {
                        if isDateInRange(date) {
                            viewModel.toggleDate(date)
                        }
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(8)
        }
    }

    private var leadingEmptyDays: Int {
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        return calendar.component(.weekday, from: firstDay) - 1
    }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }

        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }

    private func isDateInRange(_ date: Date) -> Bool {
        let normalizedDate = calendar.startOfDay(for: date)
        return normalizedDate >= startDate && normalizedDate <= endDate
    }
}

struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let isTargetDate: Bool
    let isInRange: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption)
                .fontWeight(isTargetDate ? .bold : .regular)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(backgroundColor)
                .border(Color.gray.opacity(0.3), width: 0.5)
        }
        .disabled(!isInRange)
    }

    private var backgroundColor: Color {
        if !isInRange {
            return Color.gray.opacity(0.1)
        }

        if isTargetDate {
            return isSelected ? Color.primaryBrown : Color.secondaryBrown.opacity(0.25)
        }

        return isSelected ? Color.accentCoral : Color.white
    }

    private var textColor: Color {
        if !isInRange {
            return Color.gray.opacity(0.3)
        }

        if isTargetDate {
            return .white
        }

        return isSelected ? .white : .black
    }
}
