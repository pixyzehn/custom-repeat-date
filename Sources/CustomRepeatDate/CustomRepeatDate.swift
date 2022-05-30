import Foundation

extension Calendar {
    /// Computes the next date which matches a given option.
    ///
    /// - parameter date: The starting date.
    /// - parameter option: The custom repeat date option.
    /// - returns: A `Date` representing the result of the search, or `nil` if a result could not be found or a calendar isn't Gregorian.
    public func nextDate(after date: Date, option: CustomRepeatDateOption) -> Date? {
        guard identifier == .gregorian else {
            return nil
        }

        switch option {
        case let .daily(frequency):
            guard 1...999 ~= frequency else {
                return nil
            }

            return self.date(byAdding: .day, value: frequency, to: date)

        case let .weekly(frequency, weekdays):
            guard 1...999 ~= frequency, !weekdays.isEmpty else {
                return nil
            }

            // Check date in the same week
            let dateInSameWeek: Date? = weekdays.compactMap {
                var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                dateComponents.weekday = $0.rawValue
                dateComponents.year = component(.year, from: date)
                dateComponents.weekOfYear = component(.weekOfYear, from: date)
                return nextDate(
                    after: date,
                    matching: dateComponents,
                    matchingPolicy: .nextTime,
                    repeatedTimePolicy: .first,
                    direction: .forward
                )
            }.sorted().first

            if let dateInSameWeek = dateInSameWeek {
                return dateInSameWeek
            }

            // Check next date based on frequency
            guard let afterDate = self.date(byAdding: .weekOfYear, value: frequency, to: startOfWeek(for: date)) else {
                return nil
            }

            return weekdays.compactMap {
                var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                dateComponents.weekday = $0.rawValue
                return nextDate(
                    after: afterDate,
                    matching: dateComponents,
                    matchingPolicy: .nextTime,
                    repeatedTimePolicy: .first,
                    direction: .forward
                )
            }.sorted().first

        case let .monthly(frequency, option):
            guard 1...999 ~= frequency else {
                return nil
            }

            switch option {
            case let .daysOfMonth(days):
                guard !days.isEmpty, days.allSatisfy({ 1 <= $0 && $0 <= 31 }) else {
                    return nil
                }

                // Check date in the same month
                let dateInSameMonth: Date? = days.compactMap {
                    guard component(.day, from: date) < $0 else {
                        return nil
                    }

                    var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                    dateComponents.day = $0
                    dateComponents.year = component(.year, from: date)
                    dateComponents.month = component(.month, from: date)
                    return nextDate(
                        after: date,
                        matching: dateComponents,
                        matchingPolicy: .nextTime,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    )
                }.sorted().first

                if let dateInSameMonth = dateInSameMonth {
                    return dateInSameMonth
                }

                // Check next date based on frequency
                guard let afterDate = self.date(byAdding: .month, value: frequency, to: startOfMonth(for: date)) else {
                    return nil
                }

                return days.compactMap {
                    var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                    dateComponents.year = component(.year, from: afterDate)
                    dateComponents.month = component(.month, from: afterDate)
                    dateComponents.day = $0
                    return nextDate(
                        after: afterDate,
                        matching: dateComponents,
                        matchingPolicy: .nextTime,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    )
                }.sorted().first

            case let .daysOfWeek(weekdayOrdinal, weekday):
                // Check date in the same month
                let dateInSameMonth: Date? = {
                    var dateComponents = self.dateComponents([.hour, .minute, .second], from: date)
                    dateComponents.year = component(.year, from: date)
                    dateComponents.month = component(.month, from: date)
                    dateComponents.weekday = weekday.rawValue
                    dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue
                    return nextDate(
                        after: date,
                        matching: dateComponents,
                        matchingPolicy: .nextTime,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    )
                }()

                if let dateInSameMonth = dateInSameMonth {
                    return dateInSameMonth
                }

                // Check next date based on frequency
                guard let afterDate = self.date(byAdding: .month, value: frequency, to: startOfMonth(for: date)) else {
                    return nil
                }

                var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                dateComponents.weekday = weekday.rawValue
                dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue
                return nextDate(
                    after: afterDate,
                    matching: dateComponents,
                    matchingPolicy: .nextTime,
                    repeatedTimePolicy: .first,
                    direction: .forward
                )
            }

        case let .yearly(frequency, option):
            guard 1...999 ~= frequency else {
                return nil
            }

            switch option {
            case let .daysOfYear(months, day):
                guard !months.isEmpty, months.allSatisfy({ 1 <= $0 && $0 <= 12 }), 1 <= day, day <= 31 else {
                    return nil
                }

                // Check date in the same year
                let dateInSameYear: Date? = months.compactMap {
                    var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                    dateComponents.year = component(.year, from: date)
                    dateComponents.month = $0
                    dateComponents.day = day
                    return nextDate(
                        after: date,
                        matching: dateComponents,
                        matchingPolicy: .nextTime,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    )
                }.sorted().first

                if let dateInSameYear = dateInSameYear {
                    return dateInSameYear
                }

                // Check next date based on frequency
                guard let afterDate = self.date(byAdding: .year, value: frequency, to: startOfYear(for: date)) else {
                    return nil
                }

                return months.compactMap {
                    var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                    dateComponents.month = $0
                    dateComponents.day = day
                    return nextDate(
                        after: afterDate,
                        matching: dateComponents,
                        matchingPolicy: .nextTime,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    )
                }.sorted().first

            case let .daysOfWeek(months, weekdayOrdinal, weekday):
                guard !months.isEmpty, months.allSatisfy({ 1 <= $0 && $0 <= 12 }) else {
                    return nil
                }

                // Check date in the same year
                let dateInSameYear: Date? = months.compactMap {
                    var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                    dateComponents.year = component(.year, from: date)
                    dateComponents.month = $0
                    dateComponents.weekday = weekday.rawValue
                    dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue
                    return nextDate(
                        after: date,
                        matching: dateComponents,
                        matchingPolicy: .nextTime,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    )
                }.sorted().first

                if let dateInSameYear = dateInSameYear {
                    return dateInSameYear
                }

                // Check next date based on frequency
                guard let afterDate = self.date(byAdding: .year, value: frequency, to: startOfYear(for: date)) else {
                    return nil
                }

                return months.compactMap {
                    var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                    dateComponents.month = $0
                    dateComponents.weekday = weekday.rawValue
                    dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue
                    return nextDate(
                        after: afterDate,
                        matching: dateComponents,
                        matchingPolicy: .nextTime,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    )
                }.sorted().first
            }
        }
    }
}
