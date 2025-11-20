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
    @State private var scrollOffsetX: CGFloat = 0
    @State private var initialGanttX: CGFloat?
    @State private var showExportAlert = false
    @State private var isExporting = false
    @State private var exportResult: (success: Int, total: Int)?

    private let dayWidth: CGFloat = 44
    private let rowHeight: CGFloat = 44
    private let titleWidth: CGFloat = 150
    private let editWidth: CGFloat = 50

    init(viewModel: GanttChartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // 現在一番左に表示されている日付のインデックスを計算
    private var currentVisibleDayIndex: Int {
        let offset = -scrollOffsetX
        let index = Int((offset / dayWidth).rounded())
        return max(0, min(index, viewModel.days.count - 1))
    }

    // 現在表示されている年月を取得
    private var currentDisplayMonth: String {
        guard currentVisibleDayIndex < viewModel.days.count else {
            return viewModel.currentMonth
        }
        let visibleDate = viewModel.days[currentVisibleDayIndex]
        return DateFormatter.monthYearFormatter.string(from: visibleDate)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // ヘッダー行（固定）
                headerRow(width: geometry.size.width)

                // ボディ部分（スクロール可能）
                bodyContent
            }
            .background(Color.appBackground.ignoresSafeArea())
        }
        .navigationTitle("ガントチャート")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showExportAlert = true
                }) {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(.primaryBrown)
                }
            }
        }
        .alert("リマインダーに追加", isPresented: $showExportAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("追加する") {
                Task {
                    isExporting = true
                    let result = await viewModel.exportToReminders()
                    exportResult = result
                    isExporting = false
                }
            }
        } message: {
            Text("ガントチャートでONにした日程をリマインダーに追加します")
        }
        .alert("エクスポート完了", isPresented: Binding(
            get: { exportResult != nil && !isExporting },
            set: { if !$0 { exportResult = nil } }
        )) {
            Button("OK") {
                exportResult = nil
            }
        } message: {
            if let result = exportResult {
                Text("\(result.total)件中\(result.success)件のリマインダーを作成しました")
            }
        }
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

    // ヘッダー行: Month Header + Day Headers
    private func headerRow(width: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Day Headersエリア（横スクロールと連動）
            HStack(spacing: 0) {
                Color.appBackground
                    .frame(width: titleWidth + editWidth)

                ZStack(alignment: .leading) {
                    Color.primaryBrown

                    dayHeaderRow
                        .offset(x: scrollOffsetX)
                }
                .frame(width: max(0, width - (titleWidth + editWidth)), height: rowHeight)
                .clipped()
            }

            // Month Header（左上に固定）
            Text(currentDisplayMonth)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: titleWidth + editWidth, height: rowHeight, alignment: .center)
                .background(Color.primaryBrown)
                .border(Color.gray.opacity(0.3), width: 0.5)
        }
        .frame(height: rowHeight)
    }

    // ボディ部分: Title│Edit列 + ganttGrid（一緒にスクロール）
    private var bodyContent: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(0..<viewModel.rowCount, id: \.self) { rowIndex in
                    HStack(spacing: 0) {
                        // Title│Edit列
                        LeftFixedColumnRow(
                            rowTitle: viewModel.getRowTitle(for: rowIndex),
                            rowIndex: rowIndex,
                            titleWidth: titleWidth,
                            editWidth: editWidth,
                            rowHeight: rowHeight,
                            selectedRow: $selectedRow
                        )

                        // DayCellの行
                        ganttRowForIndex(rowIndex)
                    }
                }
            }
            .background(
                GeometryReader { geo in
                    let frame = geo.frame(in: .named("scroll"))
                    Color.clear
                        .onChange(of: frame.origin.x) { newX in
                            if let initialX = initialGanttX {
                                scrollOffsetX = newX - initialX
                            } else {
                                initialGanttX = 0
                                scrollOffsetX = newX
                            }
                        }
                }
            )
        }
        .scrollBounceBehavior(.basedOnSize)
        .coordinateSpace(name: "scroll")
    }

    // 特定の行のgantt部分
    private func ganttRowForIndex(_ rowIndex: Int) -> some View {
        HStack(spacing: 0) {
            ForEach(viewModel.days.indices, id: \.self) { dayIndex in
                let date = viewModel.days[dayIndex]
                let elementIndex = viewModel.getElementIndex(for: rowIndex)
                let actionIndex = viewModel.getActionIndex(for: rowIndex)
                let isOn = viewModel.getDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
                let isTarget = viewModel.isTargetDate(date)

                DayCell(isOn: isOn, isTargetDate: isTarget)
                    .frame(width: dayWidth, height: rowHeight)
                    .border(Color.gray.opacity(0.3), width: 0.5)
                    .onTapGesture {
                        viewModel.toggleDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
                    }
            }
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
        .frame(width: CGFloat(viewModel.days.count) * dayWidth, height: rowHeight)
    }

}

struct DayCell: View {
    let isOn: Bool
    let isTargetDate: Bool

    var body: some View {
        Rectangle()
            .fill(backgroundColor)
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

// Title│Edit列の1行
struct LeftFixedColumnRow: View {
    let rowTitle: String
    let rowIndex: Int
    let titleWidth: CGFloat
    let editWidth: CGFloat
    let rowHeight: CGFloat
    @Binding var selectedRow: Int?

    var body: some View {
        HStack(spacing: 0) {
            Text(rowTitle)
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
