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

    var body: some View {
        VStack(spacing: 0) {
            // スクロール可能なコンテンツ
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(spacing: 0) {
                    // ヘッダー行
                    HStack(spacing: 0) {
                        // 月ヘッダー（左上）
                        Text(viewModel.currentMonth)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: titleWidth + editWidth, height: rowHeight)
                            .background(Color.primaryBrown)
                            .border(Color.gray.opacity(0.3), width: 0.5)

                        // 日付ヘッダー
                        LazyHStack(spacing: 0) {
                            ForEach(0..<viewModel.totalDays, id: \.self) { dayIndex in
                                let date = viewModel.date(at: dayIndex)
                                let isTarget = viewModel.isTargetDate(date)

                                VStack(spacing: 2) {
                                    Text(DateFormatter.dayFormatter.string(from: date))
                                        .font(.caption)
                                        .fontWeight(isTarget ? .bold : .regular)
                                        .foregroundColor(.white)

                                    Text(DateFormatter.weekdaySymbol(for: date))
                                        .font(.caption2)
                                        .fontWeight(isTarget ? .bold : .regular)
                                        .foregroundColor(.white)
                                }
                                .frame(width: dayWidth, height: rowHeight)
                                .background(isTarget ? Color.accentCoral : Color.primaryBrown)
                                .border(Color.gray.opacity(0.3), width: 0.5)
                            }
                        }
                    }

                    // データ行
                    ForEach(0..<viewModel.rowCount, id: \.self) { rowIndex in
                        let isElementRow = viewModel.isElementRow(for: rowIndex)

                        HStack(spacing: 0) {
                            // タイトル
                            Text(viewModel.getRowTitle(for: rowIndex))
                                .font(.caption)
                                .fontWeight(isElementRow ? .bold : .regular)
                                .lineLimit(3)
                                .minimumScaleFactor(0.7)
                                .frame(width: titleWidth, height: rowHeight)
                                .background(isElementRow ? Color(red: 211/255, green: 197/255, blue: 178/255) : Color.lightBackground)
                                .border(Color.gray.opacity(0.3), width: 0.5)

                            if isElementRow {
                                // 要素行：編集ボタンの代わりに空白
                                Rectangle()
                                    .fill(Color(red: 211/255, green: 197/255, blue: 178/255))
                                    .frame(width: editWidth, height: rowHeight)
                                    .border(Color.gray.opacity(0.3), width: 0.5)

                                // 日付セル（要素行用 - 全行動に反映）
                                ElementDayCells(
                                    viewModel: viewModel,
                                    rowIndex: rowIndex,
                                    dayWidth: dayWidth,
                                    rowHeight: rowHeight
                                )
                            } else {
                                // 行動行：編集ボタン
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

                                // 日付セル
                                ActionDayCells(
                                    viewModel: viewModel,
                                    rowIndex: rowIndex,
                                    dayWidth: dayWidth,
                                    rowHeight: rowHeight
                                )
                            }
                        }
                    }
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(viewModel.goalText.isEmpty ? "ガントチャート" : viewModel.goalText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    NotificationCenter.default.post(name: .navigateToHome, object: nil)
                }) {
                    Image(systemName: "house.fill")
                        .foregroundColor(.primaryBrown)
                }
            }
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
                    startDate: viewModel.startDate,
                    endDate: viewModel.endDate
                )
            )
        }
        .onAppear {
            viewModel.reloadData()
        }
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

// 要素行のセル行を生成
struct ElementDayCells: View {
    let viewModel: GanttChartViewModel
    let rowIndex: Int
    let dayWidth: CGFloat
    let rowHeight: CGFloat

    var body: some View {
        LazyHStack(spacing: 0) {
            ForEach(0..<viewModel.totalDays, id: \.self) { dayIndex in
                ElementDayCell(
                    viewModel: viewModel,
                    rowIndex: rowIndex,
                    dayIndex: dayIndex,
                    dayWidth: dayWidth,
                    rowHeight: rowHeight
                )
            }
        }
    }
}

struct ElementDayCell: View {
    let viewModel: GanttChartViewModel
    let rowIndex: Int
    let dayIndex: Int
    let dayWidth: CGFloat
    let rowHeight: CGFloat

    var body: some View {
        let date = viewModel.date(at: dayIndex)
        let elementIndex = viewModel.getElementIndex(for: rowIndex)
        let isAnyActionOn = viewModel.isAnyActionOnForElement(elementIndex: elementIndex, date: date)
        let isTarget = viewModel.isTargetDate(date)

        DayCell(isOn: isAnyActionOn, isTargetDate: isTarget)
            .frame(width: dayWidth, height: rowHeight)
            .border(Color.gray.opacity(0.3), width: 0.5)
            .onTapGesture {
                viewModel.toggleAllActionsForElement(elementIndex: elementIndex, date: date)
            }
    }
}

// 行動行のセル行を生成
struct ActionDayCells: View {
    let viewModel: GanttChartViewModel
    let rowIndex: Int
    let dayWidth: CGFloat
    let rowHeight: CGFloat

    var body: some View {
        LazyHStack(spacing: 0) {
            ForEach(0..<viewModel.totalDays, id: \.self) { dayIndex in
                ActionDayCell(
                    viewModel: viewModel,
                    rowIndex: rowIndex,
                    dayIndex: dayIndex,
                    dayWidth: dayWidth,
                    rowHeight: rowHeight
                )
            }
        }
    }
}

struct ActionDayCell: View {
    let viewModel: GanttChartViewModel
    let rowIndex: Int
    let dayIndex: Int
    let dayWidth: CGFloat
    let rowHeight: CGFloat

    var body: some View {
        let date = viewModel.date(at: dayIndex)
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

struct RowSelection: Identifiable {
    let id = UUID()
    let rowIndex: Int
}
