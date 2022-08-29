import Foundation

extension Calendar {
    /// Return the first day of a given week, keepting the time.
    func startOfWeek(for date: Date) -> Date {
        var components: Set<Calendar.Component> = [.calendar, .yearForWeekOfYear, .weekOfYear]
        components.formUnion([.hour, .minute, .second])
        return self.date(from: dateComponents(components, from: date))!
    }

    /// Return the first day of a given month, keepting the time.
    func startOfMonth(for date: Date) -> Date {
        var components: Set<Calendar.Component> = [.year, .month]
        components.formUnion([.hour, .minute, .second])
        return self.date(from: dateComponents(components, from: date))!
    }

    /// Return the last day of a given month, keepting the time.
    func endOfMonth(for date: Date) -> Date {
        self.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth(for: date))!
    }

    /// Return the first day of a given year, keepting the time.
    func startOfYear(for date: Date) -> Date {
        var components: Set<Calendar.Component> = [.year]
        components.formUnion([.hour, .minute, .second])
        return self.date(from: dateComponents(components, from: date))!
    }
}
