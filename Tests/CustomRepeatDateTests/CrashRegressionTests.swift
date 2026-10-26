@testable import CustomRepeatDate
import Foundation
import Testing

struct CrashRegressionTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private var options: [CustomRepeatDateOption] {
        [
            .daily(frequency: 1),
            .weekly(frequency: 1, weekdays: [.monday]),
            .monthly(frequency: 1, option: .daysOfMonth(days: [31, -1])),
            .monthly(frequency: 1, option: .daysOfWeek(weekdayOrdinal: .fifth, weekday: .monday)),
            .yearly(frequency: 1, option: .daysOfYear(months: [2, 12])),
            .yearly(frequency: 1, option: .daysOfWeek(months: [2, 12], weekdayOrdinal: .fifth, weekday: .monday)),
        ]
    }

    @Test(arguments: [
        Double.nan, .infinity, -.infinity, .greatestFiniteMagnitude,
        -.greatestFiniteMagnitude, -62_135_769_601, 253_402_300_800,
    ])
    func unsupportedDatesReturnNil(seconds: Double) {
        let date = Date(timeIntervalSince1970: seconds)
        for option in options {
            #expect(calendar.nextDate(after: date, option: option) == nil)
        }
        #expect(calendar.startOfWeek(for: date) == nil)
        #expect(calendar.startOfMonth(for: date) == nil)
        #expect(calendar.endOfMonth(for: date) == nil)
        #expect(calendar.startOfYear(for: date) == nil)
    }

    @Test func recurrenceStopsAtUpperBoundary() {
        let date = Date(timeIntervalSince1970: 253_402_300_799)
        for option in options {
            #expect(calendar.nextDate(after: date, option: option) == nil)
        }
    }

    @Test(arguments: [Int.min, Int.max])
    func extremeIntegerInputsReturnNil(value: Int) {
        let date = Date(timeIntervalSince1970: 0)
        let invalidOptions: [CustomRepeatDateOption] = [
            .daily(frequency: value),
            .weekly(frequency: value, weekdays: [.monday]),
            .monthly(frequency: value, option: .daysOfMonth(days: [1])),
            .monthly(frequency: value, option: .daysOfWeek(weekdayOrdinal: .first, weekday: .monday)),
            .yearly(frequency: value, option: .daysOfYear(months: [1])),
            .yearly(frequency: value, option: .daysOfWeek(months: [1], weekdayOrdinal: .first, weekday: .monday)),
            .monthly(frequency: 1, option: .daysOfMonth(days: [value])),
            .yearly(frequency: 1, option: .daysOfYear(months: [value])),
            .yearly(frequency: 1, option: .daysOfWeek(months: [value], weekdayOrdinal: .first, weekday: .monday)),
        ]
        for option in invalidOptions {
            #expect(calendar.nextDate(after: date, option: option) == nil)
        }
    }

    @Test(arguments: ["GMT", "America/Los_Angeles", "Pacific/Apia"])
    func boundarySearchesAdvanceOrTerminate(timeZone: String) throws {
        var calendar = calendar
        calendar.timeZone = try #require(TimeZone(identifier: timeZone))
        for seconds: Double in [-62_135_769_600, -62_135_683_200, 253_370_764_800] {
            let date = Date(timeIntervalSince1970: seconds)
            for option in options {
                if let next = calendar.nextDate(after: date, option: option) {
                    #expect(next > date)
                    #expect(next.isSupportedRepeatDate)
                }
            }
        }
    }

    @Test func currentYearMatchSurvivesFailedFutureAdvance() throws {
        let start = try #require(calendar.date(from: DateComponents(year: 9999, month: 1, day: 1)))
        let next = try #require(calendar.nextDate(
            after: start, option: .yearly(frequency: 999, option: .daysOfYear(months: [12]))
        ))
        #expect(calendar.component(.year, from: next) == 9999)
        #expect(calendar.component(.month, from: next) == 12)
    }

    @Test func supportedBoundsMatchGregorianYears() throws {
        let first = try #require(calendar.date(from: DateComponents(year: 1, month: 1, day: 1)))
        let end = try #require(calendar.date(from: DateComponents(year: 10000, month: 1, day: 1)))
        #expect(first.timeIntervalSince1970 == -62_135_769_600)
        #expect(end.timeIntervalSince1970 == 253_402_300_800)
        #expect(first.isSupportedRepeatDate)
        #expect(!end.isSupportedRepeatDate)
    }

    @Test func duplicateSelectionsProduceSameDate() {
        let date = Date(timeIntervalSince1970: 0)
        let pairs: [(CustomRepeatDateOption, CustomRepeatDateOption)] = [
            (.weekly(frequency: 1, weekdays: [.monday]), .weekly(frequency: 1, weekdays: [.monday, .monday])),
            (.monthly(frequency: 1, option: .daysOfMonth(days: [31])), .monthly(frequency: 1, option: .daysOfMonth(days: [31, 31]))),
            (.yearly(frequency: 1, option: .daysOfYear(months: [2])), .yearly(frequency: 1, option: .daysOfYear(months: [2, 2]))),
        ]
        for (single, duplicate) in pairs {
            #expect(calendar.nextDate(after: date, option: single) == calendar.nextDate(after: date, option: duplicate))
        }
    }
}
