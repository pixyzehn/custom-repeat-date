import Foundation

public extension Calendar {
    /// Computes the next date which matches a given option.
    ///
    /// - parameter date: The starting date, within years 1 through 9999 CE (UTC).
    /// - parameter option: The custom repeat date option.
    /// - returns: A later date within the supported range, or `nil` if no result
    ///   exists, the input is invalid, or the calendar is not Gregorian.
    func nextDate(after date: Date, option: CustomRepeatDateOption) -> Date? {
        guard identifier == .gregorian, date.isSupportedRepeatDate,
              component(.era, from: date) == 1 else {
            return nil
        }
        guard let result = nextRepeatDate(after: date, option: option),
              result.isSupportedRepeatDate, result > date else {
            return nil
        }
        return result
    }

    private func nextRepeatDate(after date: Date, option: CustomRepeatDateOption) -> Date? {
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

            // A Gregorian 400-year cycle contains 20,871 weeks.
            for _ in 0 ... 20_871 {
                var result = [Date]()
                for weekday in Set(weekdays) {
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
                      nextWeek.start > week.start, nextWeek.start.isSupportedRepeatDate else {
                    return nil
                }
                week = nextWeek
            }
            return nil

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
                let timeComponents = dateComponents([.hour, .minute, .second, .nanosecond], from: date)
                let maxMonthIterations = 4800 / gcd(4800, frequency)
                guard let currentMonth = dateInterval(of: .month, for: date)?.start else {
                    return nil
                }

                for day in Set(days) {
                    var targetMonth = currentMonth
                    // Include this month, then search one complete Gregorian cycle.
                    for _ in 0 ... maxMonthIterations {
                        let targetDay = day == lastDay
                            ? range(of: .day, in: .month, for: targetMonth)?.last
                            : day
                        if let targetDay,
                           let matchingDate = fixedDayDate(
                               year: component(.year, from: targetMonth),
                               month: component(.month, from: targetMonth),
                               day: targetDay,
                               timeComponents: timeComponents
                           ), matchingDate > date {
                            result.append(matchingDate)
                            break
                        }

                        // Missing dates, including timezone-skipped days, must not
                        // terminate the recurrence or change its frequency.
                        guard let nextMonth = self.date(byAdding: .month, value: frequency, to: targetMonth),
                              nextMonth > targetMonth, nextMonth.isSupportedRepeatDate else {
                            break
                        }
                        targetMonth = nextMonth
                    }
                }

                return result.min()

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
                guard let monthStart = startOfMonth(for: date),
                      var afterDate = advancing(.month, by: frequency, from: monthStart) else {
                    return result.min()
                }

                for _ in 0 ..< maxMonthIterations {
                    let targetYear = component(.year, from: afterDate)
                    let targetMonth = component(.month, from: afterDate)
                    if let matchingDate = weekdayOrdinalDate(
                        year: targetYear,
                        month: targetMonth,
                        timeComponents: timeComponents,
                        weekdayOrdinal: weekdayOrdinal,
                        weekday: weekday
                    ) {
                        result.append(matchingDate)
                        break
                    }

                    guard let next = advancing(.month, by: frequency, from: afterDate) else { break }
                    afterDate = next
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
                let afterDate = startOfYear(for: date).flatMap { advancing(.year, by: frequency, from: $0) }
                let maxYearIterations = 400 / gcd(400, frequency)

                for month in Set(months).sorted() {
                    if let matchingDate = fixedDayDate(
                        year: year,
                        month: month,
                        day: day,
                        timeComponents: timeComponents
                    ),
                        matchingDate > date {
                        result.append(matchingDate)
                    }

                    guard var targetDate = afterDate else { continue }
                    for _ in 0 ..< maxYearIterations {
                        var afterDateComponents = self.dateComponents([.hour, .minute, .second, .nanosecond], from: targetDate)
                        afterDateComponents.year = component(.year, from: targetDate)
                        afterDateComponents.month = month
                        afterDateComponents.day = day

                        if let matchingDate = fixedDayDate(from: afterDateComponents) {
                            result.append(matchingDate)
                            break
                        }

                        guard let next = advancing(.year, by: frequency, from: targetDate) else { break }
                        targetDate = next
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
                let sortedMonths = Set(months).sorted()

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
                guard let yearStart = startOfYear(for: date),
                      let baseAfterDate = advancing(.year, by: frequency, from: yearStart) else {
                    return result.min()
                }

                for month in sortedMonths {
                    var afterDate = baseAfterDate
                    for _ in 0 ..< maxYearIterations {
                        let targetYear = component(.year, from: afterDate)
                        if let matchingDate = weekdayOrdinalDate(
                            year: targetYear,
                            month: month,
                            timeComponents: timeComponents,
                            weekdayOrdinal: weekdayOrdinal,
                            weekday: weekday
                        ) {
                            result.append(matchingDate)
                            break
                        }

                        guard let next = advancing(.year, by: frequency, from: afterDate) else { break }
                        afterDate = next
                    }
                }

                return result.sorted().first
            }
        }
    }

    private func advancing(_ component: Calendar.Component, by value: Int, from date: Date) -> Date? {
        guard let next = self.date(byAdding: component, value: value, to: date),
              next.isSupportedRepeatDate, next > date else {
            return nil
        }
        return next
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
              component(.month, from: matchingDate) == month,
              component(.weekday, from: matchingDate) == weekday.rawValue else {
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
