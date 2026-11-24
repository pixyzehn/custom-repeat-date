import CustomRepeatDate
import Foundation
import Testing

struct RecurrencesTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        calendar.firstWeekday = Weekday.monday.rawValue
        return calendar
    }

    private func date(
        _ year: Int, _ month: Int, _ day: Int,
        hour: Int = 9, minute: Int = 0, calendar: Calendar
    ) throws -> Date {
        try #require(calendar.date(from: DateComponents(
            year: year, month: month, day: day, hour: hour, minute: minute
        )))
    }

    @Test func rangeKeepsMonthlyCadenceAndUsesHalfOpenBounds() throws {
        let start = try date(2026, 1, 13, calendar: calendar)
        let february = try date(2026, 2, 1, calendar: calendar)
        let march = try date(2026, 3, 10, calendar: calendar)
        let may = try date(2026, 5, 12, calendar: calendar)
        let july = try date(2026, 7, 14, calendar: calendar)
        let option = CustomRepeatDateOption.monthly(frequency: 2, option: .daysOfWeek(weekdayOrdinal: .second, weekday: .tuesday))
        let all = calendar.recurrences(of: option, startingAt: start)
        let range = february ..< july

        #expect(Array(all.prefix(4)) == [start, march, may, july])
        #expect(Array(calendar.recurrences(of: option, startingAt: start, in: range)) == [march, may])
        #expect(Array(calendar.recurrences(of: option, startingAt: start, in: march ..< may)) == [march])
        #expect(Array(all.prefix(1)) == [start])

        let legacyNext = try date(2026, 2, 10, calendar: calendar)
        #expect(calendar.nextDate(after: february, option: option) == legacyNext)
    }

    @Test func weeklyRestoresOriginalLocalTimeAfterDaylightSavingGap() throws {
        var calendar = self.calendar
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let start = try date(2026, 3, 1, hour: 2, minute: 30, calendar: calendar)
        let shifted = try date(2026, 3, 8, hour: 3, minute: 30, calendar: calendar)
        let restored = try date(2026, 3, 15, hour: 2, minute: 30, calendar: calendar)
        let option = CustomRepeatDateOption.weekly(frequency: 1, weekdays: [.sunday])

        let dates = calendar.recurrences(of: option, startingAt: start).prefix(3)
        #expect(Array(dates) == [start, shifted, restored])

        let legacyNext = try date(2026, 3, 15, hour: 3, minute: 30, calendar: calendar)
        #expect(calendar.nextDate(after: start, option: option) == shifted)
        #expect(calendar.nextDate(after: shifted, option: option) == legacyNext)
    }

    @Test(arguments: [(Weekday.monday.rawValue, [11, 19, 25]), (Weekday.sunday.rawValue, [18, 19])])
    func weeklyRespectsFirstWeekdayAcrossInactiveWeeks(firstWeekday: Int, days: [Int]) throws {
        var calendar = self.calendar
        calendar.firstWeekday = firstWeekday
        let start = try date(2026, 1, 7, calendar: calendar)
        let end = try date(2026, 2, 1, calendar: calendar)
        let option = CustomRepeatDateOption.weekly(frequency: 2, weekdays: [.monday, .sunday, .monday])
        let expected = try days.map { try date(2026, 1, $0, calendar: calendar) }

        #expect(Array(calendar.recurrences(of: option, startingAt: start, in: start ..< end)) == expected)
    }

    @Test func dailySkipsMissingLocalDayWithoutShiftingCadence() throws {
        var calendar = self.calendar
        calendar.timeZone = try #require(TimeZone(identifier: "Pacific/Apia"))
        let start = try date(2011, 12, 28, calendar: calendar)
        let januaryFirst = try date(2012, 1, 1, calendar: calendar)
        let januaryThird = try date(2012, 1, 3, calendar: calendar)
        let option = CustomRepeatDateOption.daily(frequency: 2)

        #expect(Array(calendar.recurrences(of: option, startingAt: start).prefix(3)) == [start, januaryFirst, januaryThird])
    }

    @Test func rangeIncludesMidnightBeforeTheLocalDateRollsBack() throws {
        var calendar = self.calendar
        calendar.timeZone = try #require(TimeZone(identifier: "America/St_Johns"))
        let start = try date(2009, 10, 31, hour: 0, calendar: calendar)
        let novemberMidnight = try date(2009, 11, 1, hour: 2, minute: 30, calendar: self.calendar)
        let afterRollback = novemberMidnight.addingTimeInterval(60)
        let option = CustomRepeatDateOption.daily(frequency: 1)

        let dates = calendar.recurrences(of: option, startingAt: start, in: start ..< afterRollback)
        #expect(Array(dates) == [start, novemberMidnight])
    }

    @Test(arguments: [([31, -1, 31], 2, 28), ([31], 3, 31)])
    func monthlyHandlesMissingAndDuplicateDays(days: [Int], nextMonth: Int, nextDay: Int) throws {
        let start = try date(2026, 1, 31, calendar: calendar)
        let second = try date(2026, nextMonth, nextDay, calendar: calendar)
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfMonth(days: days))

        #expect(Array(calendar.recurrences(of: option, startingAt: start).prefix(2)) == [start, second])
    }

    @Test func yearlyUsesOriginalDayInEachSelectedMonth() throws {
        let start = try date(2024, 1, 29, calendar: calendar)
        let expected = try [(2024, 2), (2024, 4), (2025, 4), (2026, 4)].map { year, month in
            try date(year, month, 29, calendar: calendar)
        }
        let option = CustomRepeatDateOption.yearly(frequency: 1, option: .daysOfYear(months: [4, 2]))

        #expect(Array(calendar.recurrences(of: option, startingAt: start).prefix(4)) == expected)
    }

    @Test func yearlySupportsOrdinalWeekdays() throws {
        let start = try date(2026, 1, 1, calendar: calendar)
        let expected = try [(2026, 26), (2028, 23), (2030, 28)].map { year, day in
            try date(year, 11, day, calendar: calendar)
        }
        let option = CustomRepeatDateOption.yearly(
            frequency: 2, option: .daysOfWeek(months: [11], weekdayOrdinal: .fourth, weekday: .thursday)
        )

        #expect(Array(calendar.recurrences(of: option, startingAt: start).prefix(3)) == expected)
    }

    @Test func sequenceEndsAtSupportedUpperBoundary() throws {
        let start = try date(9999, 12, 31, calendar: calendar)
        let firstUnsupportedDate = try date(10000, 1, 1, calendar: calendar)
        let option = CustomRepeatDateOption.daily(frequency: 1)

        #expect(Array(calendar.recurrences(of: option, startingAt: start)) == [start])
        #expect(Array(calendar.recurrences(of: option, startingAt: firstUnsupportedDate).prefix(1)).isEmpty)
    }

    @Test func sequenceEndsWhenTheSelectedMonthNeverHasTheSelectedDay() throws {
        let start = try date(2026, 2, 1, calendar: calendar)
        let option = CustomRepeatDateOption.monthly(frequency: 12, option: .daysOfMonth(days: [30]))

        #expect(Array(calendar.recurrences(of: option, startingAt: start).prefix(1)).isEmpty)
    }

    @Test func invalidInputsProduceAnEmptySequence() throws {
        let start = try date(2026, 1, 1, calendar: calendar)
        let daily = CustomRepeatDateOption.daily(frequency: 1)
        let invalidDate = Date(timeIntervalSince1970: .infinity)

        #expect(Array(calendar.recurrences(of: .daily(frequency: 0), startingAt: start).prefix(1)).isEmpty)
        #expect(Array(calendar.recurrences(of: .weekly(frequency: 1, weekdays: []), startingAt: start).prefix(1)).isEmpty)
        #expect(Array(calendar.recurrences(of: daily, startingAt: invalidDate).prefix(1)).isEmpty)
        #expect(Array(calendar.recurrences(of: daily, startingAt: start, in: start ..< start)).isEmpty)
        #expect(Array(Calendar(identifier: .hebrew).recurrences(of: daily, startingAt: start).prefix(1)).isEmpty)
    }

    @Test func existingCodableRepresentationRoundTrips() throws {
        let json = #"{"monthly":{"frequency":3,"option":{"daysOfWeek":{"weekday":3,"weekdayOrdinal":2}}}}"#
        let option = try JSONDecoder().decode(CustomRepeatDateOption.self, from: Data(json.utf8))
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        #expect(option == .monthly(frequency: 3, option: .daysOfWeek(weekdayOrdinal: .second, weekday: .tuesday)))
        #expect(try encoder.encode(option) == Data(json.utf8))
    }
}
