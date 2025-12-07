//
//  UserDefaultsDataSource.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

class UserDefaultsDataSource {
    private let userDefaults = UserDefaults.standard
    private var planId: String?

    // MARK: - Plan ID Management
    func setPlanId(_ id: String) {
        self.planId = id
    }

    // MARK: - Keys
    private enum Keys {
        static func goalText(planId: String) -> String {
            return "mokuhyou_\(planId)"
        }

        static func targetDate(planId: String) -> String {
            return "kikan_\(planId)"
        }

        static func startDate(planId: String) -> String {
            return "startDate_\(planId)"
        }

        static func element(planId: String, index: Int) -> String {
            return "youso\(index)_\(planId)"
        }

        static func action(planId: String, elementIndex: Int, actionIndex: Int) -> String {
            return "koudou\(elementIndex)\(actionIndex)_\(planId)"
        }

        static func dayState(planId: String, elementIndex: Int, actionIndex: Int, date: String) -> String {
            let rowIndex = (elementIndex - 1) * 4 + actionIndex
            return "onoff_\(rowIndex)_\(date)_\(planId)"
        }
    }

    // MARK: - Goal
    func saveGoalText(_ text: String) {
        guard let planId = planId else { return }
        userDefaults.set(text, forKey: Keys.goalText(planId: planId))
    }

    func getGoalText() -> String? {
        guard let planId = planId else { return nil }
        return userDefaults.string(forKey: Keys.goalText(planId: planId))
    }

    func saveStartDate(_ date: Date) {
        guard let planId = planId else { return }
        userDefaults.set(date, forKey: Keys.startDate(planId: planId))
    }

    func getStartDate() -> Date? {
        guard let planId = planId else { return nil }
        return userDefaults.object(forKey: Keys.startDate(planId: planId)) as? Date
    }

    func saveTargetDate(_ date: Date) {
        guard let planId = planId else { return }
        userDefaults.set(date, forKey: Keys.targetDate(planId: planId))
    }

    func getTargetDate() -> Date? {
        guard let planId = planId else { return nil }
        return userDefaults.object(forKey: Keys.targetDate(planId: planId)) as? Date
    }

    // MARK: - Elements
    func saveElement(_ text: String, at index: Int) {
        guard let planId = planId else { return }
        userDefaults.set(text, forKey: Keys.element(planId: planId, index: index))
    }

    func getElement(at index: Int) -> String? {
        guard let planId = planId else { return nil }
        return userDefaults.string(forKey: Keys.element(planId: planId, index: index))
    }

    // MARK: - Actions
    func saveAction(_ text: String, elementIndex: Int, actionIndex: Int) {
        guard let planId = planId else { return }
        userDefaults.set(text, forKey: Keys.action(planId: planId, elementIndex: elementIndex, actionIndex: actionIndex))
    }

    func getAction(elementIndex: Int, actionIndex: Int) -> String? {
        guard let planId = planId else { return nil }
        return userDefaults.string(forKey: Keys.action(planId: planId, elementIndex: elementIndex, actionIndex: actionIndex))
    }

    // MARK: - Day States
    func saveDayState(elementIndex: Int, actionIndex: Int, date: Date, isOn: Bool) {
        guard let planId = planId else { return }
        let dateString = dateFormatter.string(from: date)
        userDefaults.set(isOn, forKey: Keys.dayState(planId: planId, elementIndex: elementIndex, actionIndex: actionIndex, date: dateString))
    }

    func getDayState(elementIndex: Int, actionIndex: Int, date: Date) -> Bool {
        guard let planId = planId else { return false }
        let dateString = dateFormatter.string(from: date)
        return userDefaults.bool(forKey: Keys.dayState(planId: planId, elementIndex: elementIndex, actionIndex: actionIndex, date: dateString))
    }

    // MARK: - Helper
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()
}
