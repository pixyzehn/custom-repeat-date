import Foundation

public extension Calendar {
    /// Computes the next date which matches a given option.
    ///
    /// - parameter date: The starting date.
    /// - parameter option: The custom repeat date option.
    /// - returns: A `Date` representing the result of the search, or `nil` if a result could not be found or a calendar isn't Gregorian.
    func nextDate(after date: Date, option: CustomRepeatDateOption) -> Date? {
        guard identifier == .gregorian else {
            return nil
        }

        switch option {
        case let .daily(frequency):
            guard 1 ... 999 ~= frequency else {
                return nil
            }

            return self.date(byAdding: .day, value: frequency, to: date)

        case let .weekly(frequency, weekdays):
            guard 1 ... 999 ~= frequency, !weekdays.isEmpty else {
                return nil
            }

            var result = [Date]()
            let weekOfYear = component(.weekOfYear, from: date)
            let afterDate = self.date(byAdding: .weekOfYear, value: frequency, to: date) ?? date

            for weekday in weekdays.sorted() {
                var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                dateComponents.weekday = weekday.rawValue

                enumerateDates(
                    startingAfter: date,
                    matching: dateComponents,
                    matchingPolicy: .strict,
                    repeatedTimePolicy: .first,
                    direction: .forward
                ) { matchingDate, _, stop in
                    guard let matchingDate = matchingDate else { stop = true; return }
                    let matchingWeekOfYear = component(.weekOfYear, from: matchingDate)
                    if matchingWeekOfYear == weekOfYear {
                        result.append(matchingDate)
                    }
                    stop = true
                }

                var afterDateComponents = self.dateComponents([.hour, .minute, .second], from: afterDate)
                afterDateComponents.weekday = weekday.rawValue

                enumerateDates(
                    startingAfter: startOfDay(for: startOfWeek(for: afterDate)),
                    matching: afterDateComponents,
                    matchingPolicy: .strict,
                    repeatedTimePolicy: .first,
                    direction: .forward
                ) { matchingDate, _, stop in
                    guard let matchingDate = matchingDate else { stop = true; return }
                    result.append(matchingDate)
                    stop = true
                }
            }

            return result.sorted().first

        case let .monthly(frequency, option):
            guard 1 ... 999 ~= frequency else {
                return nil
            }

            switch option {
            case let .daysOfMonth(days):
                let lastDay = CustomRepeatDateOption.MonthlyOption.lastDay
                guard !days.isEmpty, days.allSatisfy({ ($0 >= 1 && $0 <= 31) || $0 == lastDay }) else {
                    return nil
                }

                var result = [Date]()
                let year = component(.year, from: date)
                let month = component(.month, from: date)
                var afterDate = self.date(byAdding: .month, value: frequency, to: startOfMonth(for: date)) ?? date
                let days: [Int] = {
                    var result = days.sorted()
                    if result.contains(lastDay) {
                        result.removeAll(where: { $0 == lastDay })
                        result.append(lastDay)
                    }
                    return result
                }()

                for day in days {
                    if day == lastDay {
                        let endOfMonth = endOfMonth(for: date)
                        if endOfMonth > date {
                            result.append(endOfMonth)
                        }
                    } else {
                        var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                        dateComponents.day = day

                        enumerateDates(
                            startingAfter: date,
                            matching: dateComponents,
                            matchingPolicy: .strict,
                            repeatedTimePolicy: .first,
                            direction: .forward
                        ) { matchingDate, _, stop in
                            guard let matchingDate = matchingDate else { stop = true; return }
                            let matchingYear = component(.year, from: matchingDate)
                            let matchingMonth = component(.month, from: matchingDate)
                            if matchingYear == year, matchingMonth == month {
                                result.append(matchingDate)
                            }
                            stop = true
                        }
                    }

                    var afterDateComponents = self.dateComponents([.hour, .minute, .second], from: afterDate)
                    afterDateComponents.day = day

                    // Update afterDate until it found the day
                    var maxDay = range(of: .day, in: .month, for: afterDate)?.count ?? 0
                    while day > maxDay {
                        afterDate = self.date(byAdding: .month, value: frequency, to: afterDate) ?? afterDate
                        maxDay = range(of: .day, in: .month, for: afterDate)?.count ?? 0
                    }

                    if day == lastDay {
                        let endOfMonth = endOfMonth(for: afterDate)
                        if endOfMonth > afterDate {
                            result.append(endOfMonth)
                        }
                    } else {
                        // Set the start of the day to be able to check the 1st on each month
                        enumerateDates(
                            startingAfter: startOfDay(for: startOfMonth(for: afterDate)),
                            matching: afterDateComponents,
                            matchingPolicy: .strict,
                            repeatedTimePolicy: .first,
                            direction: .forward
                        ) { matchingDate, _, stop in
                            guard let matchingDate = matchingDate else { stop = true; return }
                            result.append(matchingDate)
                            stop = true
                        }
                    }
                }

                return result.sorted().first

            case let .daysOfWeek(weekdayOrdinal, weekday):
                var result = [Date]()
                let year = component(.year, from: date)
                let month = component(.month, from: date)
                let afterDate = self.date(byAdding: .month, value: frequency, to: startOfMonth(for: date)) ?? date

                if weekdayOrdinal == .last {
                    var dateComponents = dateComponents([.year, .month, .hour, .minute, .second], from: date)
                    dateComponents.weekday = weekday.rawValue
                    dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue

                    if let matchingDate = self.date(from: dateComponents), matchingDate > date {
                        result.append(matchingDate)
                    }
                } else {
                    var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                    dateComponents.weekday = weekday.rawValue
                    dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue

                    enumerateDates(
                        startingAfter: date,
                        matching: dateComponents,
                        matchingPolicy: .strict,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    ) { matchingDate, _, stop in
                        guard let matchingDate = matchingDate else { stop = true; return }
                        let matchingYear = component(.year, from: matchingDate)
                        let matchingMonth = component(.month, from: matchingDate)
                        if matchingYear == year, matchingMonth == month {
                            result.append(matchingDate)
                        }
                        stop = true
                    }
                }

                if weekdayOrdinal == .last {
                    var dateComponents = dateComponents([.year, .month, .hour, .minute, .second], from: startOfMonth(for: afterDate))
                    dateComponents.weekday = weekday.rawValue
                    dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue

                    if let matchingDate = self.date(from: dateComponents) {
                        result.append(matchingDate)
                    }
                } else {
                    var afterDateComponents = self.dateComponents([.hour, .minute, .second], from: afterDate)
                    afterDateComponents.weekday = weekday.rawValue
                    afterDateComponents.weekdayOrdinal = weekdayOrdinal.rawValue

                    enumerateDates(
                        startingAfter: startOfMonth(for: afterDate),
                        matching: afterDateComponents,
                        matchingPolicy: .strict,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    ) { matchingDate, _, stop in
                        guard let matchingDate = matchingDate else { stop = true; return }
                        result.append(matchingDate)
                        stop = true
                    }
                }

                return result.sorted().first
            }

        case let .yearly(frequency, option):
            guard 1 ... 999 ~= frequency else {
                return nil
            }

            switch option {
            case let .daysOfYear(months):
                guard !months.isEmpty, months.allSatisfy({ $0 >= 1 && $0 <= 12 }) else {
                    return nil
                }

                var result = [Date]()
                let year = component(.year, from: date)
                let day = component(.day, from: date)
                let afterDate = self.date(byAdding: .year, value: frequency, to: startOfYear(for: date)) ?? date

                for month in months.sorted() {
                    var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                    dateComponents.month = month
                    dateComponents.day = day

                    enumerateDates(
                        startingAfter: date,
                        matching: dateComponents,
                        matchingPolicy: .strict,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    ) { matchingDate, _, stop in
                        guard let matchingDate = matchingDate else { stop = true; return }
                        let matchingYear = component(.year, from: matchingDate)
                        if matchingYear == year {
                            result.append(matchingDate)
                        }
                        stop = true
                    }

                    var afterDateComponents = self.dateComponents([.hour, .minute, .second], from: afterDate)
                    afterDateComponents.month = month
                    afterDateComponents.day = day

                    enumerateDates(
                        startingAfter: startOfYear(for: afterDate),
                        matching: afterDateComponents,
                        matchingPolicy: .strict,
                        repeatedTimePolicy: .first,
                        direction: .forward
                    ) { matchingDate, _, stop in
                        guard let matchingDate = matchingDate else { stop = true; return }
                        result.append(matchingDate)
                        stop = true
                    }
                }

                return result.sorted().first

            case let .daysOfWeek(months, weekdayOrdinal, weekday):
                guard !months.isEmpty, months.allSatisfy({ $0 >= 1 && $0 <= 12 }) else {
                    return nil
                }

                var result = [Date]()
                let year = component(.year, from: date)
                let afterDate = self.date(byAdding: .year, value: frequency, to: startOfYear(for: date)) ?? date

                for month in months.sorted() {
                    if weekdayOrdinal == .last {
                        var dateComponents = dateComponents([.year, .hour, .minute, .second], from: date)
                        dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue
                        dateComponents.weekday = weekday.rawValue
                        dateComponents.month = month

                        if let matchingDate = self.date(from: dateComponents), matchingDate > date {
                            result.append(matchingDate)
                        }
                    } else {
                        var dateComponents = dateComponents([.hour, .minute, .second], from: date)
                        dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue
                        dateComponents.weekday = weekday.rawValue
                        dateComponents.month = month

                        enumerateDates(
                            startingAfter: date,
                            matching: dateComponents,
                            matchingPolicy: .strict,
                            repeatedTimePolicy: .first,
                            direction: .forward
                        ) { matchingDate, _, stop in
                            guard let matchingDate = matchingDate else { stop = true; return }
                            let matchingYear = component(.year, from: matchingDate)
                            if matchingYear == year {
                                result.append(matchingDate)
                            }
                            stop = true
                        }
                    }

                    if weekdayOrdinal == .last {
                        var dateComponents = dateComponents([.year, .hour, .minute, .second], from: startOfYear(for: afterDate))
                        dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue
                        dateComponents.weekday = weekday.rawValue
                        dateComponents.month = month

                        if let matchingDate = self.date(from: dateComponents) {
                            result.append(matchingDate)
                        }
                    } else {
                        var afterDateComponents = self.dateComponents([.hour, .minute, .second], from: afterDate)
                        afterDateComponents.weekdayOrdinal = weekdayOrdinal.rawValue
                        afterDateComponents.weekday = weekday.rawValue
                        afterDateComponents.month = month

                        enumerateDates(
                            startingAfter: startOfYear(for: afterDate),
                            matching: afterDateComponents,
                            matchingPolicy: .strict,
                            repeatedTimePolicy: .first,
                            direction: .forward
                        ) { matchingDate, _, stop in
                            guard let matchingDate = matchingDate else { stop = true; return }
                            result.append(matchingDate)
                            stop = true
                        }
                    }
                }

                return result.sorted().first
            }
        }
    }
}
