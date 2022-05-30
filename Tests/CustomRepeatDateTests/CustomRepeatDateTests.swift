import XCTest
@testable import CustomRepeatDate

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

    func testYearlyCustomRepeatDateDaysOfYear() {
        let option = CustomRepeatDateOption.yearly(frequency: 3, option: .daysOfYear(months: [1, 4], day: 12))

        let repeat1 = calendar.nextDate(after: date(year: 2022, month: 5, day: 5), option: option)!
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
}
