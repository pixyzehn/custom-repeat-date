@testable import CustomRepeatDate
import XCTest

final class CustomRepeatDateTests: XCTestCase {
    lazy var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2 // Set Monday as first weekday
        return calendar
    }()

    func date(year: Int, month: Int, day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 22
        dateComponents.minute = 22
        dateComponents.second = 22
        return calendar.date(from: dateComponents)!
    }

    // MARK: - Daily

    func testDailyCustomRepeatDate() {
        let option = CustomRepeatDateOption.daily(frequency: 2)

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 5, day: 7))
        XCTAssertEqual(repeat2, date(year: 2022, month: 5, day: 9))
        XCTAssertEqual(repeat3, date(year: 2022, month: 5, day: 11))
        XCTAssertEqual(repeat4, date(year: 2022, month: 5, day: 13))
        XCTAssertEqual(repeat5, date(year: 2022, month: 5, day: 15))
    }

    // MARK: - Weekly

    func testWeeklyCustomRepeatDate() {
        let option = CustomRepeatDateOption.weekly(frequency: 2, weekdays: [.friday])

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 5, day: 6))
        XCTAssertEqual(repeat2, date(year: 2022, month: 5, day: 20))
        XCTAssertEqual(repeat3, date(year: 2022, month: 6, day: 3))
        XCTAssertEqual(repeat4, date(year: 2022, month: 6, day: 17))
        XCTAssertEqual(repeat5, date(year: 2022, month: 7, day: 1))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.friday.rawValue)
        }
    }

    func testWeeklyCustomRepeatDateWithYearUpdate() {
        let option = CustomRepeatDateOption.weekly(frequency: 2, weekdays: [.sunday])

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 12, day: 18), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2023, month: 1, day: 1))
        XCTAssertEqual(repeat2, date(year: 2023, month: 1, day: 15))
        XCTAssertEqual(repeat3, date(year: 2023, month: 1, day: 29))
        XCTAssertEqual(repeat4, date(year: 2023, month: 2, day: 12))
        XCTAssertEqual(repeat5, date(year: 2023, month: 2, day: 26))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.sunday.rawValue)
        }
    }

    func testWeeklyCustomRepeatDateWithMultipleWeekdays() {
        let option = CustomRepeatDateOption.weekly(frequency: 2, weekdays: [.sunday, .monday])

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 5, day: 8))
        XCTAssertEqual(repeat2, date(year: 2022, month: 5, day: 16))
        XCTAssertEqual(repeat3, date(year: 2022, month: 5, day: 22))
        XCTAssertEqual(repeat4, date(year: 2022, month: 5, day: 30))
        XCTAssertEqual(repeat5, date(year: 2022, month: 6, day: 5))

        let weekdays = [Weekday.sunday.rawValue, Weekday.monday.rawValue]
        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertTrue(weekdays.contains(calendar.component(.weekday, from: date)))
        }
    }

    func testWeeklyCustomRepeatDateWithMaxFrequency() {
        let option = CustomRepeatDateOption.weekly(frequency: 999, weekdays: [.sunday])

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 12, day: 18), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2042, month: 2, day: 9))
        XCTAssertEqual(repeat2, date(year: 2061, month: 4, day: 3))
        XCTAssertEqual(repeat3, date(year: 2080, month: 5, day: 26))
        XCTAssertEqual(repeat4, date(year: 2099, month: 7, day: 19))
        XCTAssertEqual(repeat5, date(year: 2118, month: 9, day: 11))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.sunday.rawValue)
        }
    }

    // MARK: - Monthly

    func testMonthlyCustomRepeatDateDaysOfMonth() {
        let option = CustomRepeatDateOption.monthly(frequency: 2, option: .daysOfMonth(days: [2, 10]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 5, day: 10))
        XCTAssertEqual(repeat2, date(year: 2022, month: 7, day: 2))
        XCTAssertEqual(repeat3, date(year: 2022, month: 7, day: 10))
        XCTAssertEqual(repeat4, date(year: 2022, month: 9, day: 2))
        XCTAssertEqual(repeat5, date(year: 2022, month: 9, day: 10))
    }

    func testMonthlyCustomRepeatDateDaysOfMonthWithSkippingCases() {
        let option = CustomRepeatDateOption.monthly(frequency: 2, option: .daysOfMonth(days: [31]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        // Skip cases where there is no 31th
        XCTAssertEqual(repeat1, date(year: 2022, month: 5, day: 31))
        XCTAssertEqual(repeat2, date(year: 2022, month: 7, day: 31))
        XCTAssertEqual(repeat3, date(year: 2023, month: 1, day: 31))
        XCTAssertEqual(repeat4, date(year: 2023, month: 3, day: 31))
        XCTAssertEqual(repeat5, date(year: 2023, month: 5, day: 31))
    }

    func testMonthlyCustomRepeatDateDaysOfMonthWithMultipleDays() {
        let option = CustomRepeatDateOption.monthly(frequency: 2, option: .daysOfMonth(days: [1, 5]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 7, day: 1))
        XCTAssertEqual(repeat2, date(year: 2022, month: 7, day: 5))
        XCTAssertEqual(repeat3, date(year: 2022, month: 9, day: 1))
        XCTAssertEqual(repeat4, date(year: 2022, month: 9, day: 5))
        XCTAssertEqual(repeat5, date(year: 2022, month: 11, day: 1))
    }

    func testMonthlyCustomRepeatDateDaysOfMonthWithMaxFrequency() {
        let option = CustomRepeatDateOption.monthly(frequency: 999, option: .daysOfMonth(days: [5]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2105, month: 8, day: 5))
        XCTAssertEqual(repeat2, date(year: 2188, month: 11, day: 5))
        XCTAssertEqual(repeat3, date(year: 2272, month: 2, day: 5))
        XCTAssertEqual(repeat4, date(year: 2355, month: 5, day: 5))
        XCTAssertEqual(repeat5, date(year: 2438, month: 8, day: 5))
    }

    func testMonthlyCustomRepeatDateDaysOfWeek() {
        let option = CustomRepeatDateOption.monthly(frequency: 3, option: .daysOfWeek(weekdayOrdinal: .second, weekday: .tuesday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 5, day: 10))
        XCTAssertEqual(repeat2, date(year: 2022, month: 8, day: 9))
        XCTAssertEqual(repeat3, date(year: 2022, month: 11, day: 8))
        XCTAssertEqual(repeat4, date(year: 2023, month: 2, day: 14))
        XCTAssertEqual(repeat5, date(year: 2023, month: 5, day: 9))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertEqual(calendar.component(.weekdayOrdinal, from: date), WeekdayOrdinal.second.rawValue)
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.tuesday.rawValue)
        }
    }

    func testMonthlyCustomRepeatDateDaysOfWeekWithSkippingCases() {
        let option = CustomRepeatDateOption.monthly(frequency: 1, option: .daysOfWeek(weekdayOrdinal: .fifth, weekday: .friday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        // Skip cases where there is no fifth friday
        XCTAssertEqual(repeat1, date(year: 2022, month: 7, day: 29))
        XCTAssertEqual(repeat2, date(year: 2022, month: 9, day: 30))
        XCTAssertEqual(repeat3, date(year: 2022, month: 12, day: 30))
        XCTAssertEqual(repeat4, date(year: 2023, month: 3, day: 31))
        XCTAssertEqual(repeat5, date(year: 2023, month: 6, day: 30))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertEqual(calendar.component(.weekdayOrdinal, from: date), WeekdayOrdinal.fifth.rawValue)
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.friday.rawValue)
        }
    }

    func testMonthlyCustomRepeatDateDaysOfWeekWithLastWeekdayOrdinal() {
        let option = CustomRepeatDateOption.monthly(frequency: 3, option: .daysOfWeek(weekdayOrdinal: .last, weekday: .monday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 5, day: 30))
        XCTAssertEqual(repeat2, date(year: 2022, month: 8, day: 29))
        XCTAssertEqual(repeat3, date(year: 2022, month: 11, day: 28))
        XCTAssertEqual(repeat4, date(year: 2023, month: 2, day: 27))
        XCTAssertEqual(repeat5, date(year: 2023, month: 5, day: 29))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertTrue([4, 5].contains(calendar.component(.weekdayOrdinal, from: date)))
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.monday.rawValue)
        }
    }

    func testMonthlyCustomRepeatDateDaysOfWeekWithMaxFrequency() {
        let option = CustomRepeatDateOption.monthly(frequency: 999, option: .daysOfWeek(weekdayOrdinal: .third, weekday: .wednesday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 5, day: 18))
        XCTAssertEqual(repeat2, date(year: 2105, month: 8, day: 19))
        XCTAssertEqual(repeat3, date(year: 2188, month: 11, day: 19))
        XCTAssertEqual(repeat4, date(year: 2272, month: 2, day: 21))
        XCTAssertEqual(repeat5, date(year: 2355, month: 5, day: 18))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertEqual(calendar.component(.weekdayOrdinal, from: date), WeekdayOrdinal.third.rawValue)
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.wednesday.rawValue)
        }
    }

    // MARK: - Yearly

    func testYearlyCustomRepeatDateDaysOfYear() {
        let option = CustomRepeatDateOption.yearly(frequency: 3, option: .daysOfYear(months: [6]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 12), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 6, day: 12))
        XCTAssertEqual(repeat2, date(year: 2025, month: 6, day: 12))
        XCTAssertEqual(repeat3, date(year: 2028, month: 6, day: 12))
        XCTAssertEqual(repeat4, date(year: 2031, month: 6, day: 12))
        XCTAssertEqual(repeat5, date(year: 2034, month: 6, day: 12))
    }

    func testYearlyCustomRepeatDateDaysOfYearWithSkippingCases() {
        let option = CustomRepeatDateOption.yearly(frequency: 3, option: .daysOfYear(months: [1, 4]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 31), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        // Skip cases where there is no 31th
        XCTAssertEqual(repeat1, date(year: 2025, month: 1, day: 31))
        XCTAssertEqual(repeat2, date(year: 2028, month: 1, day: 31))
        XCTAssertEqual(repeat3, date(year: 2031, month: 1, day: 31))
        XCTAssertEqual(repeat4, date(year: 2034, month: 1, day: 31))
        XCTAssertEqual(repeat5, date(year: 2037, month: 1, day: 31))
    }

    func testYearlyCustomRepeatDateDaysOfYearWithMultipleMonths() {
        let option = CustomRepeatDateOption.yearly(frequency: 3, option: .daysOfYear(months: [1, 4]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 12), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2025, month: 1, day: 12))
        XCTAssertEqual(repeat2, date(year: 2025, month: 4, day: 12))
        XCTAssertEqual(repeat3, date(year: 2028, month: 1, day: 12))
        XCTAssertEqual(repeat4, date(year: 2028, month: 4, day: 12))
        XCTAssertEqual(repeat5, date(year: 2031, month: 1, day: 12))
    }

    func testYearlyCustomRepeatDateDaysOfYearWithMaxFrequency() {
        let option = CustomRepeatDateOption.yearly(frequency: 999, option: .daysOfYear(months: [1, 4]))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 10), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 3021, month: 1, day: 10))
        XCTAssertEqual(repeat2, date(year: 3021, month: 4, day: 10))
        XCTAssertEqual(repeat3, date(year: 4020, month: 1, day: 10))
        XCTAssertEqual(repeat4, date(year: 4020, month: 4, day: 10))
        XCTAssertEqual(repeat5, date(year: 5019, month: 1, day: 10))
    }

    func testYearlyCustomRepeatDateDaysOfWeek() {
        let option = CustomRepeatDateOption.yearly(frequency: 2, option: .daysOfWeek(months: [3, 8, 9], weekdayOrdinal: .first, weekday: .saturday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 8, day: 6))
        XCTAssertEqual(repeat2, date(year: 2022, month: 9, day: 3))
        XCTAssertEqual(repeat3, date(year: 2024, month: 3, day: 2))
        XCTAssertEqual(repeat4, date(year: 2024, month: 8, day: 3))
        XCTAssertEqual(repeat5, date(year: 2024, month: 9, day: 7))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertEqual(calendar.component(.weekdayOrdinal, from: date), WeekdayOrdinal.first.rawValue)
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.saturday.rawValue)
        }
    }

    func testYearlyCustomRepeatDateDaysOfWeekWithSkippingCases() {
        let option = CustomRepeatDateOption.yearly(frequency: 2, option: .daysOfWeek(months: [3, 8, 9], weekdayOrdinal: .fifth, weekday: .friday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        // Skip cases where there is no fifth friday
        XCTAssertEqual(repeat1, date(year: 2022, month: 9, day: 30))
        XCTAssertEqual(repeat2, date(year: 2024, month: 3, day: 29))
        XCTAssertEqual(repeat3, date(year: 2024, month: 8, day: 30))
        XCTAssertEqual(repeat4, date(year: 2028, month: 3, day: 31))
        XCTAssertEqual(repeat5, date(year: 2028, month: 9, day: 29))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertEqual(calendar.component(.weekdayOrdinal, from: date), WeekdayOrdinal.fifth.rawValue)
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.friday.rawValue)
        }
    }

    func testYearlyCustomRepeatDateDaysOfWeekWithLastWeekdayOrdinal() {
        let option = CustomRepeatDateOption.yearly(frequency: 2, option: .daysOfWeek(months: [3, 8, 9], weekdayOrdinal: .last, weekday: .monday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 8, day: 29))
        XCTAssertEqual(repeat2, date(year: 2022, month: 9, day: 26))
        XCTAssertEqual(repeat3, date(year: 2024, month: 3, day: 25))
        XCTAssertEqual(repeat4, date(year: 2024, month: 8, day: 26))
        XCTAssertEqual(repeat5, date(year: 2024, month: 9, day: 30))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertTrue([4, 5].contains(calendar.component(.weekdayOrdinal, from: date)))
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.monday.rawValue)
        }
    }

    func testYearlyCustomRepeatDateDaysOfWeekWithMaxFrequency() {
        let option = CustomRepeatDateOption.yearly(frequency: 999, option: .daysOfWeek(months: [3, 8, 9], weekdayOrdinal: .second, weekday: .tuesday))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
        let repeat2 = calendar.nextDate(after: repeat1, option: option)!
        let repeat3 = calendar.nextDate(after: repeat2, option: option)!
        let repeat4 = calendar.nextDate(after: repeat3, option: option)!
        let repeat5 = calendar.nextDate(after: repeat4, option: option)!

        XCTAssertEqual(repeat1, date(year: 2022, month: 8, day: 9))
        XCTAssertEqual(repeat2, date(year: 2022, month: 9, day: 13))
        XCTAssertEqual(repeat3, date(year: 3021, month: 3, day: 13))
        XCTAssertEqual(repeat4, date(year: 3021, month: 8, day: 14))
        XCTAssertEqual(repeat5, date(year: 3021, month: 9, day: 11))

        for date in [repeat1, repeat2, repeat3, repeat4, repeat5] {
            XCTAssertEqual(calendar.component(.weekdayOrdinal, from: date), WeekdayOrdinal.second.rawValue)
            XCTAssertEqual(calendar.component(.weekday, from: date), Weekday.tuesday.rawValue)
        }
    }
}
