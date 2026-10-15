@testable import CustomRepeatDate
import Foundation
import Testing

struct TimeZoneRegressionTests {
    private func calendar(_ timeZone: String) throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: timeZone))
        return calendar
    }

    private func date(_ calendar: Calendar, _ year: Int, _ month: Int, _ day: Int, hour: Int = 12, minute: Int = 0) throws -> Date {
        try #require(calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)))
    }

    @Test func monthlyWeekdayPreservesTimeAcrossMonthStartGap() throws {
        let calendar = try calendar("Australia/Lord_Howe")
        let start = try date(calendar, 2023, 9, 10, hour: 2, minute: 15)
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfWeek(weekdayOrdinal: .second, weekday: .sunday))

        #expect(try calendar.nextDate(after: start, option: option) == date(calendar, 2023, 10, 8, hour: 2, minute: 15))
    }

    @Test(arguments: [8, 9, 10])
    func monthlyLastDayPreservesTimeAcrossMonthStartGap(month: Int) throws {
        let calendar = try calendar("Australia/Lord_Howe")
        let start = try date(calendar, 2023, month, 10, hour: 2, minute: 15)
        let lastDay = try #require(calendar.range(of: .day, in: .month, for: start)?.last)
        let expected = try date(calendar, 2023, month, lastDay, hour: 2, minute: 15)
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfMonth(days: [-1]))

        #expect(calendar.endOfMonth(for: start) == expected)
        #expect(calendar.nextDate(after: start, option: option) == expected)
        let nextMonth = try #require(calendar.date(byAdding: .month, value: 1, to: date(calendar, 2023, month, 1)))
        let nextLastDay = try #require(calendar.range(of: .day, in: .month, for: nextMonth)?.last)
        #expect(try calendar.nextDate(after: expected, option: option) == date(calendar, 2023, month + 1, nextLastDay, hour: 2, minute: 15))
    }

    @Test(arguments: [1, 3])
    func monthlyContinuesAfterSkippedDate(frequency: Int) throws {
        let calendar = try calendar("Pacific/Apia")
        let start = try date(calendar, 2011, 12 - frequency, 30)
        let option = CustomRepeatDateOption.monthly(frequency: frequency, option: .daysOfMonth(days: [30]))

        #expect(try calendar.nextDate(after: start, option: option) == date(calendar, 2012, frequency, 30))
    }

    @Test func monthlyConsidersOtherDaysWhenDateIsSkipped() throws {
        let calendar = try calendar("Pacific/Apia")
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfMonth(days: [30, 31]))

        #expect(try calendar.nextDate(after: date(calendar, 2011, 11, 30), option: option) == date(calendar, 2011, 12, 31))
    }

    @Test func monthlyRejectsNormalizedWeekday() throws {
        let calendar = try calendar("Pacific/Apia")
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfWeek(weekdayOrdinal: .last, weekday: .friday))

        #expect(try calendar.nextDate(after: date(calendar, 2011, 12, 1), option: option) == date(calendar, 2012, 1, 27))
    }

    @Test func yearlyRejectsNormalizedWeekday() throws {
        let calendar = try calendar("Pacific/Apia")
        let option = CustomRepeatDateOption.yearly(frequency: 1, option: .daysOfWeek(months: [12], weekdayOrdinal: .last, weekday: .friday))

        #expect(try calendar.nextDate(after: date(calendar, 2011, 12, 1), option: option) == date(calendar, 2012, 12, 28))
    }
}
