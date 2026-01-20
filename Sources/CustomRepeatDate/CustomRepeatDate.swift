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

                // Set the start of the day - 1s to be able to include the start of the week
                let startingAfter = startOfDay(for: startOfWeek(for: afterDate)).addingTimeInterval(-1)
                enumerateDates(
                    startingAfter: startingAfter,
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
                let baseAfterDate = self.date(byAdding: .month, value: frequency, to: startOfMonth(for: date)) ?? date
                let days: [Int] = {
                    var result = days.sorted()
                    if result.contains(lastDay) {
                        result.removeAll(where: { $0 == lastDay })
                        result.append(lastDay)
                    }
                    return result
                }()

                for day in days {
                    var afterDate = baseAfterDate

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

                    // Update afterDate until it found the day
                    if day != lastDay {
                        var maxDay = range(of: .day, in: .month, for: afterDate)?.count ?? 0
                        while day > maxDay {
                            afterDate = self.date(byAdding: .month, value: frequency, to: afterDate) ?? afterDate
                            maxDay = range(of: .day, in: .month, for: afterDate)?.count ?? 0
                        }
                    }

                    if day == lastDay {
                        let endOfMonth = endOfMonth(for: afterDate)
                        if endOfMonth > afterDate {
                            result.append(endOfMonth)
                        }
                    } else {
                        var afterDateComponents = dateComponents([.hour, .minute, .second], from: afterDate)
                        afterDateComponents.day = day

                        // Set the start of the day - 1s to be able to include the start of the month
                        let startingAfter = startOfDay(for: startOfMonth(for: afterDate)).addingTimeInterval(-1)
                        enumerateDates(
                            startingAfter: startingAfter,
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
                let timeComponents = dateComponents([.hour, .minute, .second], from: date)
                let year = component(.year, from: date)
                let month = component(.month, from: date)

                if let matchingDate = weekdayOrdinalDate(
                    year: year,
                    month: month,
                    timeComponents: timeComponents,
                    weekdayOrdinal: weekdayOrdinal,
                    weekday: weekday
                ),
                    matchingDate > date {
                    result.append(matchingDate)
                }

                let maxMonthIterations = 4800 / gcd(4800, frequency)
                var afterDate = self.date(byAdding: .month, value: frequency, to: startOfMonth(for: date)) ?? date
                let afterTimeComponents = dateComponents([.hour, .minute, .second], from: afterDate)

                for _ in 0 ..< maxMonthIterations {
                    let targetYear = component(.year, from: afterDate)
                    let targetMonth = component(.month, from: afterDate)
                    if let matchingDate = weekdayOrdinalDate(
                        year: targetYear,
                        month: targetMonth,
                        timeComponents: afterTimeComponents,
                        weekdayOrdinal: weekdayOrdinal,
                        weekday: weekday
                    ) {
                        result.append(matchingDate)
                        break
                    }

                    afterDate = self.date(byAdding: .month, value: frequency, to: afterDate) ?? afterDate
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

                    // Set the start of the day -1s to be able to include the start of the year
                    let startingAfter = startOfDay(for: startOfYear(for: afterDate)).addingTimeInterval(-1)
                    enumerateDates(
                        startingAfter: startingAfter,
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
                let timeComponents = dateComponents([.hour, .minute, .second], from: date)
                let year = component(.year, from: date)
                let sortedMonths = months.sorted()

                for month in sortedMonths {
                    if let matchingDate = weekdayOrdinalDate(
                        year: year,
                        month: month,
                        timeComponents: timeComponents,
                        weekdayOrdinal: weekdayOrdinal,
                        weekday: weekday
                    ),
                        matchingDate > date {
                        result.append(matchingDate)
                    }
                }

                let maxYearIterations = 400 / gcd(400, frequency)
                let baseAfterDate = self.date(byAdding: .year, value: frequency, to: startOfYear(for: date)) ?? date
                let afterTimeComponents = dateComponents([.hour, .minute, .second], from: baseAfterDate)

                for month in sortedMonths {
                    var afterDate = baseAfterDate
                    for _ in 0 ..< maxYearIterations {
                        let targetYear = component(.year, from: afterDate)
                        if let matchingDate = weekdayOrdinalDate(
                            year: targetYear,
                            month: month,
                            timeComponents: afterTimeComponents,
                            weekdayOrdinal: weekdayOrdinal,
                            weekday: weekday
                        ) {
                            result.append(matchingDate)
                            break
                        }

                        afterDate = self.date(byAdding: .year, value: frequency, to: afterDate) ?? afterDate
                    }
                }

                return result.sorted().first
            }
        }
    }

    private func weekdayOrdinalDate(
        year: Int,
        month: Int,
        timeComponents: DateComponents,
        weekdayOrdinal: WeekdayOrdinal,
        weekday: Weekday
    ) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        dateComponents.weekdayOrdinal = weekdayOrdinal.rawValue
        dateComponents.weekday = weekday.rawValue

        guard let matchingDate = self.date(from: dateComponents) else {
            return nil
        }

        guard component(.year, from: matchingDate) == year,
              component(.month, from: matchingDate) == month else {
            return nil
        }

        return matchingDate
    }
}

private func gcd(_ lhs: Int, _ rhs: Int) -> Int {
    var a = lhs
    var b = rhs
    while b != 0 {
        let remainder = a % b
        a = b
        b = remainder
    }
    return a
}
