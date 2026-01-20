@testable import CustomRepeatDate
import Testing
import Foundation

struct CustomRepeatDateValidationTests {
    var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2 // Set Monday as first weekday
        return calendar
    }()

    func date(year: Int, month: Int, day: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour ?? 22
        dateComponents.minute = minute ?? 22
        dateComponents.second = second ?? 22
        return calendar.date(from: dateComponents)!
    }

    @Test func nonGregorianCalendarReturnsNil() {
        var isoCalendar = Calendar(identifier: .iso8601)
        isoCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let option = CustomRepeatDateOption.daily(frequency: 1)

        #expect(isoCalendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option) == nil)
    }

    @Test func dailyFrequencyOutsideRangeReturnsNil() {
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .daily(frequency: 0)) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .daily(frequency: 1000)) == nil)
    }

    @Test func weeklyValidationReturnsNil() {
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .weekly(frequency: 0, weekdays: [.monday])) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .weekly(frequency: 1000, weekdays: [.monday])) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .weekly(frequency: 1, weekdays: [])) == nil)
    }

    @Test func monthlyValidationReturnsNil() {
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .monthly(frequency: 0, option: .daysOfMonth(days: [1]))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .monthly(frequency: 1000, option: .daysOfMonth(days: [1]))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .monthly(frequency: 1, option: .daysOfMonth(days: []))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .monthly(frequency: 1, option: .daysOfMonth(days: [0]))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .monthly(frequency: 1, option: .daysOfMonth(days: [32]))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .monthly(frequency: 1, option: .daysOfMonth(days: [-2]))) == nil)
    }

    @Test func yearlyValidationReturnsNil() {
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .yearly(frequency: 0, option: .daysOfYear(months: [1]))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .yearly(frequency: 1000, option: .daysOfYear(months: [1]))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .yearly(frequency: 1, option: .daysOfYear(months: []))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .yearly(frequency: 1, option: .daysOfYear(months: [0]))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .yearly(frequency: 1, option: .daysOfYear(months: [13]))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .yearly(frequency: 1, option: .daysOfWeek(months: [0], weekdayOrdinal: .first, weekday: .monday))) == nil)
        #expect(calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: .yearly(frequency: 1, option: .daysOfWeek(months: [13], weekdayOrdinal: .first, weekday: .monday))) == nil)
    }
}
