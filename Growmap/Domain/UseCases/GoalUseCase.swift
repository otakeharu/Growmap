//
//  GoalUseCase.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation
import EventKit

class GoalUseCase {
    private let repository: GoalRepositoryProtocol
    let planUseCase: PlanUseCase?

    init(repository: GoalRepositoryProtocol, planUseCase: PlanUseCase? = nil) {
        self.repository = repository
        self.planUseCase = planUseCase
    }

    func setPlanId(_ planId: String) {
        repository.setPlanId(planId)
    }

    func updateEditProgress(_ progress: EditProgress) {
        planUseCase?.updateEditProgress(progress)
    }

    func saveGoal(_ goal: Goal) {
        repository.saveGoal(goal)
    }

    func getGoal() -> Goal? {
        repository.getGoal()
    }

    func saveElements(_ elements: [Element]) {
        repository.saveElements(elements)
    }

    func getElements() -> [Element] {
        repository.getElements()
    }

    func saveDayState(_ state: DayState) {
        repository.saveDayState(state)
    }

    func getDayState(elementIndex: Int, actionIndex: Int, date: Date) -> Bool {
        repository.getDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
    }

    func toggleDayState(elementIndex: Int, actionIndex: Int, date: Date) {
        let currentState = getDayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date)
        let newState = DayState(elementIndex: elementIndex, actionIndex: actionIndex, date: date, isOn: !currentState)
        saveDayState(newState)
    }

    // リマインダーエクスポート用のデータを取得
    func getReminderData() -> [(actionName: String, date: Date, elementName: String)] {
        var reminderData: [(String, Date, String)] = []
        let elements = getElements()

        guard let goal = getGoal() else { return [] }
        let startDate = Calendar.current.startOfDay(for: goal.startDate)
        let endDate = Calendar.current.startOfDay(for: goal.targetDate)

        // 全ての日付をループ
        var currentDate = startDate
        while currentDate <= endDate {
            // 全ての要素と行動をループ
            for (elementIndex, element) in elements.enumerated() {
                for (actionIndex, action) in element.actions.enumerated() {
                    // ONの日付のみ抽出
                    if getDayState(elementIndex: elementIndex + 1, actionIndex: actionIndex + 1, date: currentDate) {
                        reminderData.append((
                            actionName: action.text,
                            date: currentDate,
                            elementName: element.text
                        ))
                    }
                }
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return reminderData
    }
}

// MARK: - ReminderManager

class ReminderManager {
    private let eventStore = EKEventStore()

    // リマインダーへのアクセス権限をリクエスト
    func requestAccess() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                return try await eventStore.requestFullAccessToReminders()
            } else {
                return try await eventStore.requestAccess(to: .reminder)
            }
        } catch {
            print("リマインダーへのアクセスが拒否されました: \(error)")
            return false
        }
    }

    // 単一のリマインダーを作成
    func createReminder(title: String, dueDate: Date, note: String? = nil) async -> Bool {
        guard await requestAccess() else { return false }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = note
        reminder.calendar = eventStore.defaultCalendarForNewReminders()

        // 期限日を設定（時刻は9:00に設定）
        var dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
        dueDateComponents.hour = 9
        dueDateComponents.minute = 0
        reminder.dueDateComponents = dueDateComponents

        do {
            try eventStore.save(reminder, commit: true)
            print("リマインダーを作成: \(title) - \(dueDate)")
            return true
        } catch {
            print("リマインダーの作成に失敗: \(error)")
            return false
        }
    }

    // ガントチャートのデータからリマインダーを一括作成
    func exportToReminders(reminderData: [(actionName: String, date: Date, elementName: String)]) async -> (success: Int, total: Int) {
        var successCount = 0

        for data in reminderData {
            let note = "要素: \(data.elementName)"
            if await createReminder(title: data.actionName, dueDate: data.date, note: note) {
                successCount += 1
            }
        }

        return (successCount, reminderData.count)
    }
}
