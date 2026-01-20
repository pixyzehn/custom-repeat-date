@testable import CustomRepeatDate
import Testing
import Foundation

struct CustomRepeatDateTests {
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

    // MARK: - Daily

    @Test func dailyCustomRepeatDate() {
        let option = CustomRepeatDateOption.daily(frequency: 2)

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 5, day: 7))
        #expect(repeat2 == date(year: 2022, month: 5, day: 9))
        #expect(repeat3 == date(year: 2022, month: 5, day: 11))
        #expect(repeat4 == date(year: 2022, month: 5, day: 13))
        #expect(repeat5 == date(year: 2022, month: 5, day: 15))
    }

    // MARK: - Weekly

    @Test func weeklyCustomRepeatDate() {
        let option = CustomRepeatDateOption.weekly(frequency: 2, weekdays: [.friday])

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 5, day: 6))
        #expect(repeat2 == date(year: 2022, month: 5, day: 20))
        #expect(repeat3 == date(year: 2022, month: 6, day: 3))
        #expect(repeat4 == date(year: 2022, month: 6, day: 17))
        #expect(repeat5 == date(year: 2022, month: 7, day: 1))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(calendar.component(.weekday, from: date) == Weekday.friday.rawValue)
        }
    }

    @Test func weeklyCustomRepeatDateWithYearUpdate() {
        let option = CustomRepeatDateOption.weekly(frequency: 2, weekdays: [.sunday])

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 12, day: 18), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2023, month: 1, day: 1))
        #expect(repeat2 == date(year: 2023, month: 1, day: 15))
        #expect(repeat3 == date(year: 2023, month: 1, day: 29))
        #expect(repeat4 == date(year: 2023, month: 2, day: 12))
        #expect(repeat5 == date(year: 2023, month: 2, day: 26))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(calendar.component(.weekday, from: date) == Weekday.sunday.rawValue)
        }
    }

    @Test func weeklyCustomRepeatDateWithMultipleWeekdays() {
        let option = CustomRepeatDateOption.weekly(frequency: 2, weekdays: [.sunday, .monday])

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 5, day: 8))
        #expect(repeat2 == date(year: 2022, month: 5, day: 16))
        #expect(repeat3 == date(year: 2022, month: 5, day: 22))
        #expect(repeat4 == date(year: 2022, month: 5, day: 30))
        #expect(repeat5 == date(year: 2022, month: 6, day: 5))

        let weekdays = [Weekday.sunday.rawValue, Weekday.monday.rawValue]
        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(weekdays.contains(calendar.component(.weekday, from: date)))
        }
    }

    @Test func weeklyCustomRepeatDateWithMaxFrequency() {
        let option = CustomRepeatDateOption.weekly(frequency: 999, weekdays: [.sunday])

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 12, day: 18), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2042, month: 2, day: 9))
        #expect(repeat2 == date(year: 2061, month: 4, day: 3))
        #expect(repeat3 == date(year: 2080, month: 5, day: 26))
        #expect(repeat4 == date(year: 2099, month: 7, day: 19))
        #expect(repeat5 == date(year: 2118, month: 9, day: 11))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(calendar.component(.weekday, from: date) == Weekday.sunday.rawValue)
        }
    }

    @Test func weeklyCustomRepeatDateFirstDayOfWeekIsIncluded() {
        let option = CustomRepeatDateOption.weekly(frequency: 1, weekdays: [.monday])

        let repeat1 = calendar.nextDate(after: date(year: 2023, month: 4, day: 3), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2023, month: 4, day: 10))
        #expect(repeat2 == date(year: 2023, month: 4, day: 17))
        #expect(repeat3 == date(year: 2023, month: 4, day: 24))
        #expect(repeat4 == date(year: 2023, month: 5, day: 1))
        #expect(repeat5 == date(year: 2023, month: 5, day: 8))
    }

    @Test func weeklyWhenStartTimeIsAtMidnight() {
        let option = CustomRepeatDateOption.weekly(frequency: 1, weekdays: [.monday])

        let repeat1 = calendar.nextDate(after: date(year: 2023, month: 8, day: 7, hour: 0, minute: 0, second: 0), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2023, month: 8, day: 14, hour: 0, minute: 0, second: 0))
        #expect(repeat2 == date(year: 2023, month: 8, day: 21, hour: 0, minute: 0, second: 0))
        #expect(repeat3 == date(year: 2023, month: 8, day: 28, hour: 0, minute: 0, second: 0))
        #expect(repeat4 == date(year: 2023, month: 9, day: 4, hour: 0, minute: 0, second: 0))
        #expect(repeat5 == date(year: 2023, month: 9, day: 11, hour: 0, minute: 0, second: 0))
    }

    // MARK: - Monthly

    @Test func monthlyCustomRepeatDateDaysOfMonth() {
        let option = CustomRepeatDateOption.monthly(frequency: 2, option: .daysOfMonth(days: [2, 10]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 5, day: 10))
        #expect(repeat2 == date(year: 2022, month: 7, day: 2))
        #expect(repeat3 == date(year: 2022, month: 7, day: 10))
        #expect(repeat4 == date(year: 2022, month: 9, day: 2))
        #expect(repeat5 == date(year: 2022, month: 9, day: 10))
    }

    @Test func monthlyCustomRepeatDateDaysOfMonthWithSkippingCases() {
        let option = CustomRepeatDateOption.monthly(frequency: 2, option: .daysOfMonth(days: [31]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        // Skip cases where there is no 31th
        #expect(repeat1 == date(year: 2022, month: 5, day: 31))
        #expect(repeat2 == date(year: 2022, month: 7, day: 31))
        #expect(repeat3 == date(year: 2023, month: 1, day: 31))
        #expect(repeat4 == date(year: 2023, month: 3, day: 31))
        #expect(repeat5 == date(year: 2023, month: 5, day: 31))
    }

    @Test func monthlyCustomRepeatDateDaysOfMonthWithLastDay() {
        let option = CustomRepeatDateOption.monthly(frequency: 2, option: .daysOfMonth(days: [-1]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        // Skip cases where there is no 31th
        #expect(repeat1 == date(year: 2022, month: 5, day: 31))
        #expect(repeat2 == date(year: 2022, month: 7, day: 31))
        #expect(repeat3 == date(year: 2022, month: 9, day: 30))
        #expect(repeat4 == date(year: 2022, month: 11, day: 30))
        #expect(repeat5 == date(year: 2023, month: 1, day: 31))
    }

    @Test func monthlyCustomRepeatDateDaysOfMonthWithLastDayAnd31() {
        let option = CustomRepeatDateOption.monthly(
            frequency: 1,
            option: .daysOfMonth(days: [31, CustomRepeatDateOption.MonthlyOption.lastDay])
        )

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 31), option: option)!

        #expect(repeat1 == date(year: 2022, month: 6, day: 30))
    }

    @Test func monthlyCustomRepeatDateDaysOfMonthWithMultipleDays() {
        let option = CustomRepeatDateOption.monthly(frequency: 2, option: .daysOfMonth(days: [1, 5]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 7, day: 1))
        #expect(repeat2 == date(year: 2022, month: 7, day: 5))
        #expect(repeat3 == date(year: 2022, month: 9, day: 1))
        #expect(repeat4 == date(year: 2022, month: 9, day: 5))
        #expect(repeat5 == date(year: 2022, month: 11, day: 1))
    }

    @Test func monthlyCustomRepeatDateDaysOfMonthWithMaxFrequency() {
        let option = CustomRepeatDateOption.monthly(frequency: 999, option: .daysOfMonth(days: [5]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2105, month: 8, day: 5))
        #expect(repeat2 == date(year: 2188, month: 11, day: 5))
        #expect(repeat3 == date(year: 2272, month: 2, day: 5))
        #expect(repeat4 == date(year: 2355, month: 5, day: 5))
        #expect(repeat5 == date(year: 2438, month: 8, day: 5))
    }

    @Test func monthlyCustomRepeatDateDaysOfWeek() {
        let option = CustomRepeatDateOption.monthly(frequency: 3, option: .daysOfWeek(weekdayOrdinal: .second, weekday: .tuesday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 5, day: 10))
        #expect(repeat2 == date(year: 2022, month: 8, day: 9))
        #expect(repeat3 == date(year: 2022, month: 11, day: 8))
        #expect(repeat4 == date(year: 2023, month: 2, day: 14))
        #expect(repeat5 == date(year: 2023, month: 5, day: 9))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(calendar.component(.weekdayOrdinal, from: date) == WeekdayOrdinal.second.rawValue)
            #expect(calendar.component(.weekday, from: date) == Weekday.tuesday.rawValue)
        }
    }

    @Test func monthlyCustomRepeatDateDaysOfWeekWithSkippingCases() {
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfWeek(weekdayOrdinal: .fifth, weekday: .friday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        // Skip cases where there is no fifth friday
        #expect(repeat1 == date(year: 2022, month: 7, day: 29))
        #expect(repeat2 == date(year: 2022, month: 9, day: 30))
        #expect(repeat3 == date(year: 2022, month: 12, day: 30))
        #expect(repeat4 == date(year: 2023, month: 3, day: 31))
        #expect(repeat5 == date(year: 2023, month: 6, day: 30))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(calendar.component(.weekdayOrdinal, from: date) == WeekdayOrdinal.fifth.rawValue)
            #expect(calendar.component(.weekday, from: date) == Weekday.friday.rawValue)
        }
    }

    @Test func monthlyCustomRepeatDateDaysOfWeekWithLastWeekdayOrdinal() {
        let option = CustomRepeatDateOption.monthly(frequency: 3, option: .daysOfWeek(weekdayOrdinal: .last, weekday: .monday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 5, day: 30))
        #expect(repeat2 == date(year: 2022, month: 8, day: 29))
        #expect(repeat3 == date(year: 2022, month: 11, day: 28))
        #expect(repeat4 == date(year: 2023, month: 2, day: 27))
        #expect(repeat5 == date(year: 2023, month: 5, day: 29))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect([4, 5].contains(calendar.component(.weekdayOrdinal, from: date)))
            #expect(calendar.component(.weekday, from: date) == Weekday.monday.rawValue)
        }
    }

    @Test func monthlyCustomRepeatDateDaysOfWeekWithMaxFrequency() {
        let option = CustomRepeatDateOption.monthly(frequency: 999, option: .daysOfWeek(weekdayOrdinal: .third, weekday: .wednesday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 5, day: 18))
        #expect(repeat2 == date(year: 2105, month: 8, day: 19))
        #expect(repeat3 == date(year: 2188, month: 11, day: 19))
        #expect(repeat4 == date(year: 2272, month: 2, day: 21))
        #expect(repeat5 == date(year: 2355, month: 5, day: 18))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(calendar.component(.weekdayOrdinal, from: date) == WeekdayOrdinal.third.rawValue)
            #expect(calendar.component(.weekday, from: date) == Weekday.wednesday.rawValue)
        }
    }

    @Test func monthlyCustomRepeatDateDaysOfMonthFirstDayOfMonthIsIncluded() {
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfMonth(days: [1]))

        let repeat1 = calendar.nextDate(after: date(year: 2023, month: 4, day: 3), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2023, month: 5, day: 1))
        #expect(repeat2 == date(year: 2023, month: 6, day: 1))
        #expect(repeat3 == date(year: 2023, month: 7, day: 1))
        #expect(repeat4 == date(year: 2023, month: 8, day: 1))
        #expect(repeat5 == date(year: 2023, month: 9, day: 1))
    }

    @Test func monthlyCustomRepeatDateDaysOfWeekFirstDayOfMonthIsIncluded() {
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfWeek(weekdayOrdinal: .first, weekday: .monday))

        let repeat1 = calendar.nextDate(after: date(year: 2023, month: 4, day: 3), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2023, month: 5, day: 1))
        #expect(repeat2 == date(year: 2023, month: 6, day: 5))
        #expect(repeat3 == date(year: 2023, month: 7, day: 3))
        #expect(repeat4 == date(year: 2023, month: 8, day: 7))
        #expect(repeat5 == date(year: 2023, month: 9, day: 4))
    }

    @Test func monthlyDaysOfMonthWhenStartTimeIsAtMidnight() {
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfMonth(days: [1]))

        let repeat1 = calendar.nextDate(after: date(year: 2023, month: 8, day: 1, hour: 0, minute: 0, second: 0), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2023, month: 9, day: 1, hour: 0, minute: 0, second: 0))
        #expect(repeat2 == date(year: 2023, month: 10, day: 1, hour: 0, minute: 0, second: 0))
        #expect(repeat3 == date(year: 2023, month: 11, day: 1, hour: 0, minute: 0, second: 0))
        #expect(repeat4 == date(year: 2023, month: 12, day: 1, hour: 0, minute: 0, second: 0))
        #expect(repeat5 == date(year: 2024, month: 1, day: 1, hour: 0, minute: 0, second: 0))
    }

    // MARK: - Yearly

    @Test func yearlyCustomRepeatDateDaysOfYear() {
        let option = CustomRepeatDateOption.yearly(frequency: 3, option: .daysOfYear(months: [6]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 12), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 6, day: 12))
        #expect(repeat2 == date(year: 2025, month: 6, day: 12))
        #expect(repeat3 == date(year: 2028, month: 6, day: 12))
        #expect(repeat4 == date(year: 2031, month: 6, day: 12))
        #expect(repeat5 == date(year: 2034, month: 6, day: 12))
    }

    @Test func yearlyCustomRepeatDateDaysOfYearIsStartOfYear() {
        let option = CustomRepeatDateOption.yearly(frequency: 1, option: .daysOfYear(months: [1]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 1, day: 1), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2023, month: 1, day: 1))
        #expect(repeat2 == date(year: 2024, month: 1, day: 1))
        #expect(repeat3 == date(year: 2025, month: 1, day: 1))
        #expect(repeat4 == date(year: 2026, month: 1, day: 1))
        #expect(repeat5 == date(year: 2027, month: 1, day: 1))
    }

    @Test func yearlyCustomRepeatDateDaysOfYearIsEndOfYear() {
        let option = CustomRepeatDateOption.yearly(frequency: 1, option: .daysOfYear(months: [12]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 12, day: 31), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!
        
        #expect(repeat1 == date(year: 2023, month: 12, day: 31))
        #expect(repeat2 == date(year: 2024, month: 12, day: 31))
        #expect(repeat3 == date(year: 2025, month: 12, day: 31))
        #expect(repeat4 == date(year: 2026, month: 12, day: 31))
        #expect(repeat5 == date(year: 2027, month: 12, day: 31))
    }

    @Test func yearlyCustomRepeatDateDaysOfYearWithSkippingCases() {
        let option = CustomRepeatDateOption.yearly(frequency: 3, option: .daysOfYear(months: [1, 4]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 31), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        // Skip cases where there is no 31th
        #expect(repeat1 == date(year: 2025, month: 1, day: 31))
        #expect(repeat2 == date(year: 2028, month: 1, day: 31))
        #expect(repeat3 == date(year: 2031, month: 1, day: 31))
        #expect(repeat4 == date(year: 2034, month: 1, day: 31))
        #expect(repeat5 == date(year: 2037, month: 1, day: 31))
    }

    @Test func yearlyCustomRepeatDateDaysOfYearWithMultipleMonths() {
        let option = CustomRepeatDateOption.yearly(frequency: 3, option: .daysOfYear(months: [1, 4]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 12), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2025, month: 1, day: 12))
        #expect(repeat2 == date(year: 2025, month: 4, day: 12))
        #expect(repeat3 == date(year: 2028, month: 1, day: 12))
        #expect(repeat4 == date(year: 2028, month: 4, day: 12))
        #expect(repeat5 == date(year: 2031, month: 1, day: 12))
    }

    @Test func yearlyCustomRepeatDateDaysOfYearWithMaxFrequency() {
        let option = CustomRepeatDateOption.yearly(frequency: 999, option: .daysOfYear(months: [1, 4]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 10), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 3021, month: 1, day: 10))
        #expect(repeat2 == date(year: 3021, month: 4, day: 10))
        #expect(repeat3 == date(year: 4020, month: 1, day: 10))
        #expect(repeat4 == date(year: 4020, month: 4, day: 10))
        #expect(repeat5 == date(year: 5019, month: 1, day: 10))
    }

    @Test func yearlyCustomRepeatDateDaysOfWeek() {
        let option = CustomRepeatDateOption.yearly(frequency: 2, option: .daysOfWeek(months: [3, 8, 9], weekdayOrdinal: .first, weekday: .saturday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 8, day: 6))
        #expect(repeat2 == date(year: 2022, month: 9, day: 3))
        #expect(repeat3 == date(year: 2024, month: 3, day: 2))
        #expect(repeat4 == date(year: 2024, month: 8, day: 3))
        #expect(repeat5 == date(year: 2024, month: 9, day: 7))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(calendar.component(.weekdayOrdinal, from: date) == WeekdayOrdinal.first.rawValue)
            #expect(calendar.component(.weekday, from: date) == Weekday.saturday.rawValue)
        }
    }

    @Test func yearlyCustomRepeatDateDaysOfWeekWithSkippingCases() {
        let option = CustomRepeatDateOption.yearly(frequency: 2, option: .daysOfWeek(months: [3, 8, 9], weekdayOrdinal: .fifth, weekday: .friday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        // Skip cases where there is no fifth friday
        #expect(repeat1 == date(year: 2022, month: 9, day: 30))
        #expect(repeat2 == date(year: 2024, month: 3, day: 29))
        #expect(repeat3 == date(year: 2024, month: 8, day: 30))
        #expect(repeat4 == date(year: 2028, month: 3, day: 31))
        #expect(repeat5 == date(year: 2028, month: 9, day: 29))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(calendar.component(.weekdayOrdinal, from: date) == WeekdayOrdinal.fifth.rawValue)
            #expect(calendar.component(.weekday, from: date) == Weekday.friday.rawValue)
        }
    }

    @Test func yearlyCustomRepeatDateDaysOfWeekWithLastWeekdayOrdinal() {
        let option = CustomRepeatDateOption.yearly(frequency: 2, option: .daysOfWeek(months: [3, 8, 9], weekdayOrdinal: .last, weekday: .monday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 8, day: 29))
        #expect(repeat2 == date(year: 2022, month: 9, day: 26))
        #expect(repeat3 == date(year: 2024, month: 3, day: 25))
        #expect(repeat4 == date(year: 2024, month: 8, day: 26))
        #expect(repeat5 == date(year: 2024, month: 9, day: 30))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect([4, 5].contains(calendar.component(.weekdayOrdinal, from: date)))
            #expect(calendar.component(.weekday, from: date) == Weekday.monday.rawValue)
        }
    }

    @Test func yearlyCustomRepeatDateDaysOfWeekWithMaxFrequency() {
        let option = CustomRepeatDateOption.yearly(frequency: 999, option: .daysOfWeek(months: [3, 8, 9], weekdayOrdinal: .second, weekday: .tuesday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2022, month: 8, day: 9))
        #expect(repeat2 == date(year: 2022, month: 9, day: 13))
        #expect(repeat3 == date(year: 3021, month: 3, day: 13))
        #expect(repeat4 == date(year: 3021, month: 8, day: 14))
        #expect(repeat5 == date(year: 3021, month: 9, day: 11))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            #expect(calendar.component(.weekdayOrdinal, from: date) == WeekdayOrdinal.second.rawValue)
            #expect(calendar.component(.weekday, from: date) == Weekday.tuesday.rawValue)
        }
    }

    @Test func yearlyCustomRepeatDateDaysOfYearFirstDayOfYearIsIncluded() {
        let option = CustomRepeatDateOption.yearly(frequency: 1, option: .daysOfYear(months: [4, 5, 6]))

        let repeat1 = calendar.nextDate(after: date(year: 2023, month: 4, day: 1), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2023, month: 5, day: 1))
        #expect(repeat2 == date(year: 2023, month: 6, day: 1))
        #expect(repeat3 == date(year: 2024, month: 4, day: 1))
        #expect(repeat4 == date(year: 2024, month: 5, day: 1))
        #expect(repeat5 == date(year: 2024, month: 6, day: 1))
    }

    @Test func yearlyCustomRepeatDateDaysOfWeekFirstDayOfYearIsIncluded() {
        let option = CustomRepeatDateOption.yearly(frequency: 1, option: .daysOfWeek(months: [4, 5, 6], weekdayOrdinal: .first, weekday: .monday))

        let repeat1 = calendar.nextDate(after: date(year: 2023, month: 4, day: 3), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        #expect(repeat1 == date(year: 2023, month: 5, day: 1))
        #expect(repeat2 == date(year: 2023, month: 6, day: 5))
        #expect(repeat3 == date(year: 2024, month: 4, day: 1))
        #expect(repeat4 == date(year: 2024, month: 5, day: 6))
        #expect(repeat5 == date(year: 2024, month: 6, day: 3))
    }
}
