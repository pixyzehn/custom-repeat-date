import Foundation

public extension Calendar {
    /// Lazily generates the dates that match a rule anchored to the original start date.
    ///
    /// The start defines the first active period, the local time, and the day of the
    /// month for yearly rules that select months. It is included if it matches the rule.
    /// Weekly periods use this calendar's first weekday. Missing calendar days are
    /// skipped. If a daylight saving gap shifts an occurrence within its day, later
    /// occurrences still use the original local time.
    ///
    /// - Parameters:
    ///   - option: The custom repeat date option.
    ///   - start: The original start date, within years 1 through 9999 CE (UTC).
    ///   - range: An optional half-open range of results. It does not reset the schedule.
    /// - Returns: Dates in increasing order. Invalid inputs and non-Gregorian
    ///   calendars produce an empty sequence. Use a range or prefix to limit the results.
    func recurrences(
        of option: CustomRepeatDateOption,
        startingAt start: Date,
        in range: Range<Date>? = nil
    ) -> some Sequence<Date> {
        guard identifier == .gregorian, start.isSupportedRepeatDate, component(.era, from: start) == 1,
              let (unit, interval) = option.recurrenceInterval, 1 ... 999 ~= interval else {
            return AnySequence<Date>([])
        }

        let limit = Date(timeIntervalSince1970: Date.repeatDateUpperLimit)
        let lowerBound = max(start, range?.lowerBound ?? start)
        let upperBound = min(limit, range?.upperBound ?? limit)
        guard lowerBound < upperBound else { return AnySequence<Date>([]) }

        // Step through civil dates in UTC, then resolve each date in the caller's
        // time zone. A skipped day or midnight cannot shift the period grid.
        var civilCalendar = self
        civilCalendar.timeZone = .gmt
        let startDayComponents = dateComponents([.era, .year, .month, .day], from: start)

        // Pad the UTC search bounds to cover all possible local dates, even
        // when a clock change rolls the local date back into the previous day.
        let earliestDay = lowerBound.addingTimeInterval(-86_400)
        let latestDay = upperBound.addingTimeInterval(86_400)
        guard let startDay = civilCalendar.date(from: startDayComponents),
              let anchorPeriod = civilCalendar.dateInterval(of: unit, for: startDay)?.start,
              let lowerPeriod = civilCalendar.dateInterval(of: unit, for: earliestDay)?.start,
              let lastPeriod = civilCalendar.dateInterval(of: unit, for: latestDay)?.start,
              let distance = civilCalendar.dateComponents([unit], from: anchorPeriod, to: lowerPeriod).value(for: unit),
              let firstPeriod = civilCalendar.date(byAdding: unit, value: max(0, distance) / interval * interval, to: anchorPeriod) else {
            return AnySequence<Date>([])
        }

        let startDayOfMonth = civilCalendar.component(.day, from: startDay)
        let startTime = dateComponents([.hour, .minute, .second, .nanosecond], from: start)
        return AnySequence {
            var period: Date? = firstPeriod
            var occurrences = [Date]().makeIterator()

            return AnyIterator<Date> {
                while true {
                    if let occurrence = occurrences.next() { return occurrence }
                    guard let currentPeriod = period, currentPeriod <= lastPeriod else { return nil }
                    period = civilCalendar.date(byAdding: unit, value: interval, to: currentPeriod)

                    let dates = civilCalendar.recurrenceDays(in: currentPeriod, option: option, startDayOfMonth: startDayOfMonth)
                    let matches = dates.compactMap { day -> Date? in
                        if day == startDay { return start }
                        guard civilCalendar.component(.era, from: day) == 1 else { return nil }
                        return fixedDayDate(
                            year: civilCalendar.component(.year, from: day),
                            month: civilCalendar.component(.month, from: day),
                            day: civilCalendar.component(.day, from: day),
                            timeComponents: startTime
                        )
                    }
                    occurrences = Set(matches.filter { lowerBound <= $0 && $0 < upperBound }).sorted().makeIterator()
                }
            }
        }
    }
}

private extension Calendar {
    func recurrenceDays(in period: Date, option: CustomRepeatDateOption, startDayOfMonth: Int) -> [Date] {
        let year = component(.year, from: period)
        let dateOnly = DateComponents()

        switch option {
        case .daily:
            return [period]
        case let .weekly(_, weekdays):
            return Set(weekdays).compactMap { weekday in
                let offset = (weekday.rawValue - firstWeekday + 7) % 7
                return date(byAdding: .day, value: offset, to: period)
            }
        case let .monthly(_, .daysOfMonth(days)):
            let month = component(.month, from: period)
            let lastDay = range(of: .day, in: .month, for: period)?.last
            return Set(days).compactMap { day in
                guard let day = day == CustomRepeatDateOption.MonthlyOption.lastDay ? lastDay : day else { return nil }
                return fixedDayDate(year: year, month: month, day: day, timeComponents: dateOnly)
            }
        case let .monthly(_, .daysOfWeek(ordinal, weekday)):
            let month = component(.month, from: period)
            return weekdayOrdinalDate(year: year, month: month, timeComponents: dateOnly, weekdayOrdinal: ordinal, weekday: weekday)
                .map { [$0] } ?? []
        case let .yearly(_, .daysOfYear(months)):
            return Set(months).compactMap { month in
                fixedDayDate(year: year, month: month, day: startDayOfMonth, timeComponents: dateOnly)
            }
        case let .yearly(_, .daysOfWeek(months, ordinal, weekday)):
            return Set(months).compactMap { month in
                weekdayOrdinalDate(year: year, month: month, timeComponents: dateOnly, weekdayOrdinal: ordinal, weekday: weekday)
            }
        }
    }
}

private extension CustomRepeatDateOption {
    var recurrenceInterval: (Calendar.Component, Int)? {
        switch self {
        case let .daily(frequency):
            return (.day, frequency)
        case let .weekly(frequency, weekdays) where !weekdays.isEmpty:
            return (.weekOfYear, frequency)
        case let .monthly(frequency, .daysOfMonth(days))
            where !days.isEmpty && days.allSatisfy({ 1 ... 31 ~= $0 || $0 == MonthlyOption.lastDay }):
            return (.month, frequency)
        case let .monthly(frequency, .daysOfWeek):
            return (.month, frequency)
        case let .yearly(frequency, .daysOfYear(months)), let .yearly(frequency, .daysOfWeek(months, _, _)):
            guard !months.isEmpty, months.allSatisfy({ 1 ... 12 ~= $0 }) else { return nil }
            return (.year, frequency)
        default:
            return nil
        }
    }
}
