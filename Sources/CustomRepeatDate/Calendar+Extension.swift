import Foundation

extension Calendar {
    /// Return the first day of a given week, keeping the time.
    func startOfWeek(for date: Date) -> Date? {
        guard date.isSupportedRepeatDate else { return nil }
        var components: Set<Calendar.Component> = [.calendar, .yearForWeekOfYear, .weekOfYear]
        components.formUnion([.hour, .minute, .second, .nanosecond])
        return self.date(from: dateComponents(components, from: date))
    }

    /// Return the first day of a given month, keeping the time.
    func startOfMonth(for date: Date) -> Date? {
        guard date.isSupportedRepeatDate else { return nil }
        var components: Set<Calendar.Component> = [.year, .month]
        components.formUnion([.hour, .minute, .second, .nanosecond])
        return self.date(from: dateComponents(components, from: date))
    }

    /// Return the last day of a given month, keeping the time.
    func endOfMonth(for date: Date) -> Date? {
        guard date.isSupportedRepeatDate else { return nil }
        guard let lastDay = range(of: .day, in: .month, for: date)?.last else {
            return nil
        }
        var components = dateComponents([.era, .year, .month, .hour, .minute, .second, .nanosecond], from: date)
        components.day = lastDay
        return self.date(from: components)
    }

    /// Return the first day of a given year, keeping the time.
    func startOfYear(for date: Date) -> Date? {
        guard date.isSupportedRepeatDate else { return nil }
        var components: Set<Calendar.Component> = [.year]
        components.formUnion([.hour, .minute, .second, .nanosecond])
        return self.date(from: dateComponents(components, from: date))
    }
}

extension Date {
    // Bound inputs before calling Foundation, which cannot safely decompose
    // arbitrary Double values. These UTC bounds cover years 1 through 9999 CE.
    var isSupportedRepeatDate: Bool {
        let seconds = timeIntervalSince1970
        return seconds.isFinite && seconds >= -62_135_769_600 && seconds < 253_402_300_800
    }
}
