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

            guard let currentWeek = dateInterval(of: .weekOfYear, for: date) else {
                return nil
            }

            let timeComponents = dateComponents([.hour, .minute, .second, .nanosecond], from: date)
            var week = currentWeek

            while true {
                var result = [Date]()
                for weekday in weekdays {
                    // Match the weekday itself because a timezone can skip a whole day.
                    guard let targetDay = nextDate(
                        after: week.start.addingTimeInterval(-1),
                        matching: DateComponents(weekday: weekday.rawValue),
                        matchingPolicy: .strict
                    ), targetDay < week.end else {
                        continue
                    }

                    // Resolve the original wall-clock time on the selected day so a
                    // DST gap cannot skip a week or change another weekday's time.
                    if let matchingDate = fixedDayDate(
                        year: component(.year, from: targetDay),
                        month: component(.month, from: targetDay),
                        day: component(.day, from: targetDay),
                        timeComponents: timeComponents
                    ), matchingDate > date {
                        result.append(matchingDate)
                    }
                }
                if let nextDate = result.min() {
                    return nextDate
                }

                // A selected weekday may not exist after a timezone skips a date.
                // Keep searching in frequency-sized steps to preserve the schedule.
                guard let nextWeekStart = self.date(byAdding: .weekOfYear, value: frequency, to: week.start),
                      let nextWeek = dateInterval(of: .weekOfYear, for: nextWeekStart),
                      nextWeek.start > week.start else {
                    return nil
                }
                week = nextWeek
            }

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
                let timeComponents = dateComponents([.hour, .minute, .second, .nanosecond], from: date)
                let baseAfterDate = self.date(byAdding: .month, value: frequency, to: startOfMonth(for: date)) ?? date
                let maxMonthIterations = 4800 / gcd(4800, frequency)
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
                        if let matchingDate = fixedDayDate(
                            year: year,
                            month: month,
                            day: day,
                            timeComponents: timeComponents
                        ),
                            matchingDate > date {
                            result.append(matchingDate)
                        }
                    }

                    // Update afterDate until it found the day
                    if day != lastDay {
                        var maxDay = range(of: .day, in: .month, for: afterDate)?.count ?? 0
                        var monthIterations = 0
                        while day > maxDay, monthIterations < maxMonthIterations {
                            afterDate = self.date(byAdding: .month, value: frequency, to: afterDate) ?? afterDate
                            maxDay = range(of: .day, in: .month, for: afterDate)?.count ?? 0
                            monthIterations += 1
                        }

                        if day > maxDay {
                            continue
                        }
                    }

                    if day == lastDay {
                        let endOfMonth = endOfMonth(for: afterDate)
                        if endOfMonth > afterDate {
                            result.append(endOfMonth)
                        }
                    } else {
                        let afterYear = component(.year, from: afterDate)
                        let afterMonth = component(.month, from: afterDate)
                        if let matchingDate = fixedDayDate(
                            year: afterYear,
                            month: afterMonth,
                            day: day,
                            timeComponents: timeComponents
                        ) {
                            result.append(matchingDate)
                        }
                    }
                }

                return result.sorted().first

            case let .daysOfWeek(weekdayOrdinal, weekday):
                var result = [Date]()
                let timeComponents = dateComponents([.hour, .minute, .second, .nanosecond], from: date)
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
                let afterTimeComponents = dateComponents([.hour, .minute, .second, .nanosecond], from: afterDate)

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
                let timeComponents = dateComponents([.hour, .minute, .second, .nanosecond], from: date)
                let afterDate = self.date(byAdding: .year, value: frequency, to: startOfYear(for: date)) ?? date
                let maxYearIterations = 400 / gcd(400, frequency)

                for month in months.sorted() {
                    if let matchingDate = fixedDayDate(
                        year: year,
                        month: month,
                        day: day,
                        timeComponents: timeComponents
                    ),
                        matchingDate > date {
                        result.append(matchingDate)
                    }

                    var targetDate = afterDate
                    for _ in 0 ..< maxYearIterations {
                        var afterDateComponents = self.dateComponents([.hour, .minute, .second, .nanosecond], from: targetDate)
                        afterDateComponents.year = component(.year, from: targetDate)
                        afterDateComponents.month = month
                        afterDateComponents.day = day

                        if let matchingDate = fixedDayDate(from: afterDateComponents) {
                            result.append(matchingDate)
                            break
                        }

                        targetDate = self.date(byAdding: .year, value: frequency, to: targetDate) ?? targetDate
                    }
                }

                return result.sorted().first

            case let .daysOfWeek(months, weekdayOrdinal, weekday):
                guard !months.isEmpty, months.allSatisfy({ $0 >= 1 && $0 <= 12 }) else {
                    return nil
                }

                var result = [Date]()
                let timeComponents = dateComponents([.hour, .minute, .second, .nanosecond], from: date)
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
                let afterTimeComponents = dateComponents([.hour, .minute, .second, .nanosecond], from: baseAfterDate)

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
        dateComponents.nanosecond = timeComponents.nanosecond
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

    private func fixedDayDate(
        year: Int,
        month: Int,
        day: Int,
        timeComponents: DateComponents
    ) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        dateComponents.nanosecond = timeComponents.nanosecond

        return fixedDayDate(from: dateComponents)
    }

    private func fixedDayDate(from dateComponents: DateComponents) -> Date? {
        guard let date = self.date(from: dateComponents) else {
            return nil
        }

        let resolvedComponents = self.dateComponents([.year, .month, .day], from: date)
        guard resolvedComponents.year == dateComponents.year,
              resolvedComponents.month == dateComponents.month,
              resolvedComponents.day == dateComponents.day else {
            return nil
        }

        return date
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
