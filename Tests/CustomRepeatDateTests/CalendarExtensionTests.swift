import XCTest
@testable import CustomRepeatDate

class CalendarExtensionTests: XCTestCase {
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

    func testStartOfWeek() {
        XCTAssertEqual(calendar.startOfWeek(for: date(year: 2022, month: 5, day: 5)), date(year: 2022, month: 5, day: 2))
        XCTAssertEqual(calendar.startOfWeek(for: date(year: 2022, month: 6, day: 2)), date(year: 2022, month: 5, day: 30))
    }

    func testStartOfMonth() {
        XCTAssertEqual(calendar.startOfMonth(for: date(year: 2022, month: 5, day: 5)), date(year: 2022, month: 5, day: 1))
        XCTAssertEqual(calendar.startOfMonth(for: date(year: 2022, month: 6, day: 25)), date(year: 2022, month: 6, day: 1))
    }

    func testStartOfYear() {
        XCTAssertEqual(calendar.startOfYear(for: date(year: 2022, month: 5, day: 5)), date(year: 2022, month: 1, day: 1))
        XCTAssertEqual(calendar.startOfYear(for: date(year: 2023, month: 10, day: 25)), date(year: 2023, month: 1, day: 1))
    }
}
