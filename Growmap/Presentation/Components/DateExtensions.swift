//
//  DateExtensions.swift
//  Growmap
//
//  Created by Haru Takenaka on 2025/10/26.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    static var jpCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ja_JP")
        return cal
    }

    static var jpLocale: Locale {
        Locale(identifier: "ja_JP")
    }
}

extension DateFormatter {
    static let ymdFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Date.jpCalendar
        formatter.locale = Date.jpLocale
        return formatter
    }()

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.calendar = Date.jpCalendar
        formatter.locale = Date.jpLocale
        return formatter
    }()

    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.calendar = Date.jpCalendar
        formatter.locale = Date.jpLocale
        return formatter
    }()

    static func weekdaySymbol(for date: Date) -> String {
        let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
        let weekday = Calendar.current.component(.weekday, from: date) - 1
        return weekdays[weekday]
    }
}
