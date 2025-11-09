//
//  UserDefaultsDataSource.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

class UserDefaultsDataSource {
    private let userDefaults = UserDefaults.standard

    // MARK: - Keys
    private enum Keys {
        static let goalText = "mokuhyou"
        static let targetDate = "kikan"
        static let elements = "elements"

        static func element(index: Int) -> String {
            return "youso\(index)"
        }

        static func action(elementIndex: Int, actionIndex: Int) -> String {
            return "koudou\(elementIndex)\(actionIndex)"
        }

        static func dayState(elementIndex: Int, actionIndex: Int, date: String) -> String {
            let rowIndex = (elementIndex - 1) * 4 + actionIndex
            return "onoff_\(rowIndex)_\(date)"
        }
    }

    // MARK: - Goal
    func saveGoalText(_ text: String) {
        userDefaults.set(text, forKey: Keys.goalText)
    }

    func getGoalText() -> String? {
        userDefaults.string(forKey: Keys.goalText)
    }

    func saveTargetDate(_ date: Date) {
        userDefaults.set(date, forKey: Keys.targetDate)
    }

    func getTargetDate() -> Date? {
        userDefaults.object(forKey: Keys.targetDate) as? Date
    }

    // MARK: - Elements
    func saveElement(_ text: String, at index: Int) {
        userDefaults.set(text, forKey: Keys.element(index: index))
    }

    func getElement(at index: Int) -> String? {
        userDefaults.string(forKey: Keys.element(index: index))
    }

    // MARK: - Actions
    func saveAction(_ text: String, elementIndex: Int, actionIndex: Int) {
        userDefaults.set(text, forKey: Keys.action(elementIndex: elementIndex, actionIndex: actionIndex))
    }

    func getAction(elementIndex: Int, actionIndex: Int) -> String? {
        userDefaults.string(forKey: Keys.action(elementIndex: elementIndex, actionIndex: actionIndex))
    }

    // MARK: - Day States
    func saveDayState(elementIndex: Int, actionIndex: Int, date: Date, isOn: Bool) {
        let dateString = dateFormatter.string(from: date)
        userDefaults.set(isOn, forKey: Keys.dayState(elementIndex: elementIndex, actionIndex: actionIndex, date: dateString))
    }

    func getDayState(elementIndex: Int, actionIndex: Int, date: Date) -> Bool {
        let dateString = dateFormatter.string(from: date)
        return userDefaults.bool(forKey: Keys.dayState(elementIndex: elementIndex, actionIndex: actionIndex, date: dateString))
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
