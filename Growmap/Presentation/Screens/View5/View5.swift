//
//  GanttChartView.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import SwiftUI

struct GanttChartView: View {
    @StateObject private var viewModel: GanttChartViewModel
    @State private var selectedRow: Int?

    private let dayWidth: CGFloat = 44
    private let rowHeight: CGFloat = 44
    private let titleWidth: CGFloat = 150
    private let editWidth: CGFloat = 50

    init(viewModel: GanttChartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            monthHeader

            HStack(spacing: 0) {
                leftFixedColumn
                ScrollView([.horizontal, .vertical]) {
                    VStack(spacing: 0) {
                        dayHeaderRow
                        ganttGrid
                    }
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("ガントチャート")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: Binding(
            get: { selectedRow.map { RowSelection(rowIndex: $0) } },
            set: { selectedRow = $0?.rowIndex }
        )) { selection in
            CalendarEditView(
                viewModel: CalendarEditViewModel(
                    useCase: viewModel.useCase,
                    rowIndex: selection.rowIndex,
                    elementIndex: viewModel.getElementIndex(for: selection.rowIndex),
                    actionIndex: viewModel.getActionIndex(for: selection.rowIndex),
                    startDate: viewModel.days.first ?? Date(),
                    endDate: viewModel.targetDate
                )
            )
        }
    }

    private var monthHeader: some View {
        HStack {
            Text(viewModel.currentMonth)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryBrown)
        }
    }

    private var leftFixedColumn: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: rowHeight)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(0..<viewModel.rowCount, id: \.self) { rowIndex in
                        HStack(spacing: 0) {
                            Text(viewModel.getRowTitle(for: rowIndex))
                                .font(.caption)
                                .lineLimit(3)
                                .minimumScaleFactor(0.7)
                                .frame(width: titleWidth, height: rowHeight)
                                .background(Color.lightBackground)
                                .border(Color.gray.opacity(0.3), width: 0.5)

                            Button(action: {
                                selectedRow = rowIndex
                            }) {
                                Text("編集")
                                    .font(.caption)
                                    .foregroundColor(.primaryBrown)
                                    .frame(width: editWidth, height: rowHeight)
                                    .background(Color.lightBackground)
                                    .border(Color.gray.opacity(0.3), width: 0.5)
                            }
                        }
                    }
                }
            }
            .frame(width: titleWidth + editWidth)
        }
    }

    private var dayHeaderRow: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.days.indices, id: \.self) { index in
                let date = viewModel.days[index]
                let isTarget = viewModel.isTargetDate(date)

                VStack(spacing: 2) {
                    Text(DateFormatter.dayFormatter.string(from: date))
                        .font(.caption)
                        .fontWeight(isTarget ? .bold : .regular)
                        .foregroundColor(isTarget ? .white : .white)

                    Text(DateFormatter.weekdaySymbol(for: date))
                        .font(.caption2)
                        .fontWeight(isTarget ? .bold : .regular)
                        .foregroundColor(isTarget ? .white : .white)
                }
                .frame(width: dayWidth, height: rowHeight)
                .background(isTarget ? Color.accentCoral : Color.primaryBrown)
                .border(Color.gray.opacity(0.3), width: 0.5)
            }
        }
    }

    private var ganttGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<viewModel.rowCount, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(viewModel.days.indices, id: \.self) { dayIndex in
                        let date = viewModel.days[dayIndex]
                        let elementIndex = viewModel.getElementIndex(for: rowIndex)
                        let actionIndex = viewModel.getActionIndex(for: rowIndex)
                        let isOn = viewModel.getDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
                        let isTarget = viewModel.isTargetDate(date)

                        DayCell(isOn: isOn, isTargetDate: isTarget)
                            .frame(width: dayWidth, height: rowHeight)
                            .onTapGesture {
                                viewModel.toggleDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
                            }
                    }
                }
            }
        }
    }
}

struct DayCell: View {
    let isOn: Bool
    let isTargetDate: Bool

    var body: some View {
        Rectangle()
            .fill(backgroundColor)
            .border(Color.gray.opacity(0.3), width: 0.5)
    }

    private var backgroundColor: Color {
        if isTargetDate {
            return isOn ? Color.accentCoral : Color.secondaryBrown.opacity(0.25)
        } else {
            return isOn ? Color.accentCoral : Color.lightBackground
        }
    }
}

struct RowSelection: Identifiable {
    let id = UUID()
    let rowIndex: Int
}
