import CustomRepeatDate
import Foundation

extension CustomRepeatDateOption {
    var name: String {
        switch self {
        case let .daily(frequency):
            if frequency == 1 {
                return "Repeat every day"
            } else {
                return "Repeat every \(frequency) days"
            }

        case let .weekly(frequency: frequency, weekdays: weekdays):
            var result = ""

            if frequency == 1 {
                result += "Repeat every week"
            } else {
                result += "Repeat every \(frequency) weeks"
            }

            result += " on \(ListFormatter.localizedString(byJoining: weekdays.map(\.name)))"
            return result

        case let .monthly(frequency: frequency, option: option):
            var result = ""

            if frequency == 1 {
                result += "Repeat every month"
            } else {
                result += "Repeat every \(frequency) months"
            }

            switch option {
            case let .daysOfMonth(days):
                if days.count == 1 {
                    return result
                } else {
                    let dayNames = days.map { "\($0)\(daySuffix(day: $0))" }
                    result += " on \(ListFormatter.localizedString(byJoining: dayNames))"
                    return result
                }
            case let .daysOfWeek(weekdayOrdinal, weekday):
                result += " on the \(weekdayOrdinal.name) \(weekday.name)"
                return result
            }

        case let .yearly(frequency: frequency, option: option):
            var result = ""

            if frequency == 1 {
                result += "Repeat every year"
            } else {
                result += "Repeat every \(frequency) years"
            }

            switch option {
            case let .daysOfYear(months):
                let monthNames = months.map { DateFormatter().monthSymbols[$0 - 1] }
                result += " in \(ListFormatter.localizedString(byJoining: monthNames))"
                return result
            case let .daysOfWeek(months, weekdayOrdinal, weekday):
                let monthNames = months.map { DateFormatter().monthSymbols[$0 - 1] }
                result += " on the \(weekdayOrdinal.name) \(weekday.name)"
                result += " of \(ListFormatter.localizedString(byJoining: monthNames))"
                return result
            }
        }
    }

    private func daySuffix(day: Int) -> String {
        switch day {
        case 11 ... 13:
            return "th"
        default:
            switch day % 10 {
            case 1:
                return "st"
            case 2:
                return "nd"
            case 3:
                return "rd"
            default:
                return "th"
            }
        }
    }
}
