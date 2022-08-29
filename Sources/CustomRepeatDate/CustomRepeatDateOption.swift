import Foundation

public enum CustomRepeatDateOption: Codable, Hashable {
    /// Event will occur every X day(s). The frequency can be 1 ~ 999.
    case daily(frequency: Int)
    /// Event will occur every X week(s) on the weekdays. The frequency can be 1 ~ 999.
    case weekly(frequency: Int, weekdays: [Weekday])
    /// Event will occur every X month(s) which matches a given option. The frequency can be 1 ~ 999.
    case monthly(frequency: Int, option: MonthlyOption)
    /// Event will occur every X year(s) which matches a given option. The frequency can be 1 ~ 999.
    case yearly(frequency: Int, option: YearlyOption)

    public enum MonthlyOption: Codable, Hashable {
        public static let lastDay = -1
        /// Days of a month, such as on the 25th and 31st. If the day is -1, it means the last day of a month.
        case daysOfMonth(days: [Int])
        /// Days of a  week, such as on the 3rd Tuesday.
        case daysOfWeek(weekdayOrdinal: WeekdayOrdinal, weekday: Weekday)
    }

    public enum YearlyOption: Codable, Hashable {
        /// Days of a year in specified months, such as on the 25th and 31st of April and August.
        case daysOfYear(months: [Int])
        /// Days of a  week in specified months, such as on the 3rd Tuesday of April and Auguest.
        case daysOfWeek(months: [Int], weekdayOrdinal: WeekdayOrdinal, weekday: Weekday)
    }
}
