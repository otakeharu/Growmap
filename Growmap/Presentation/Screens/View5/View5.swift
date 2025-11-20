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
    @State private var scrollOffsetY: CGFloat = 0
    @State private var initialGanttX: CGFloat?
    @State private var initialGanttY: CGFloat?

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
                ZStack(alignment: .topLeading) {
                    // メインのScrollView（Title│Edit列の幅分右にオフセット）
                    HStack(spacing: 0) {
                        Color.clear
                            .frame(width: titleWidth + editWidth)

                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            VStack(spacing: 0) {
                                // ヘッダー行のスペース（固定Day Headersの下に隠れる）
                                Color.clear
                                    .frame(height: rowHeight)

                                // ガントグリッド（自由にスクロール）
                                ganttGrid
                                    .background(
                                        GeometryReader { geo in
                                            let frame = geo.frame(in: .named("scroll"))
                                            Color.clear
                                                .onChange(of: frame.origin.x) { newX in
                                                    if let initialX = initialGanttX {
                                                        scrollOffsetX = newX - initialX
                                                    }
                                                }
                                                .onChange(of: frame.origin.y) { newY in
                                                    if let initialY = initialGanttY {
                                                        scrollOffsetY = newY - initialY
                                                    }
                                                }
                                                .onAppear {
                                                    initialGanttX = frame.origin.x
                                                    initialGanttY = frame.origin.y
                                                }
                                        }
                                    )
                            }
                            .frame(
                                width: CGFloat(viewModel.days.count) * dayWidth,
                                height: rowHeight + CGFloat(viewModel.rowCount) * rowHeight
                            )
                        }
                        .coordinateSpace(name: "scroll")
                    }

                    // 固定要素（ZStackで上に重ねる）
                    // Month Header（左上、完全固定）
                    Text(currentDisplayMonth)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: titleWidth + editWidth, height: rowHeight, alignment: .center)
                        .background(Color.primaryBrown)
                        .border(Color.gray.opacity(0.3), width: 0.5)
                        .offset(x: 0, y: 0)

                    // Day Headers（上部固定、横スクロールと連動）
                    ZStack(alignment: .leading) {
                        Color.primaryBrown

                        dayHeaderRow
                            .offset(x: scrollOffsetX)
                    }
                    .frame(width: max(0, geometry.size.width - (titleWidth + editWidth)), height: rowHeight)
                    .clipped()
                    .offset(x: titleWidth + editWidth, y: 0)

                    // Title│Edit列（左側固定、縦スクロールと連動）
                    ZStack(alignment: .topLeading) {
                        Color.lightBackground

                        VStack(spacing: 0) {
                            ForEach(0..<viewModel.rowCount, id: \.self) { rowIndex in
                                LeftFixedColumnRow(
                                    rowTitle: viewModel.getRowTitle(for: rowIndex),
                                    rowIndex: rowIndex,
                                    titleWidth: titleWidth,
                                    editWidth: editWidth,
                                    rowHeight: rowHeight,
                                    selectedRow: $selectedRow
                                )
                            }
                        }
                        .offset(y: scrollOffsetY)
                    }
                    .frame(width: titleWidth + editWidth, height: max(0, geometry.size.height - rowHeight))
                    .clipped()
                    .offset(x: 0, y: rowHeight)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
        }
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
                            .border(Color.gray.opacity(0.3), width: 0.5)
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

// Title│Edit列（左側固定）
struct LeftFixedColumn: View {
    @ObservedObject var viewModel: GanttChartViewModel
    let scrollOffsetY: CGFloat
    let titleWidth: CGFloat
    let editWidth: CGFloat
    let rowHeight: CGFloat
    @Binding var selectedRow: Int?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Color.lightBackground

                VStack(spacing: 0) {
                    ForEach(0..<viewModel.rowCount, id: \.self) { rowIndex in
                        LeftFixedColumnRow(
                            rowTitle: viewModel.getRowTitle(for: rowIndex),
                            rowIndex: rowIndex,
                            titleWidth: titleWidth,
                            editWidth: editWidth,
                            rowHeight: rowHeight,
                            selectedRow: $selectedRow
                        )
                    }
                }
                //.offset(y: scrollOffsetY)
            }
            .frame(width: titleWidth + editWidth, height: geometry.size.height)
            .clipped()
        }
    }
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
