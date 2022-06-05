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
        case .weekly(frequency: let frequency, weekdays: let weekdays):
            var result = ""

            if frequency == 1 {
                result += "Repeat every week"
            } else {
                result += "Repeat every \(frequency) weeks"
            }

            result += " on \(ListFormatter().string(from: weekdays.map { $0.name })!)"
            return result
        case .monthly(frequency: let frequency, option: let option):
            var result = ""

            if frequency == 1 {
                result += "Repeat every month"
            } else {
                result += "Repeat every \(frequency) months"
            }

            switch option {
            case .daysOfMonth(let days):
                if days.count == 1 {
                    return result
                } else {
                    let dayNames = days.map { "\($0)\(daySuffix(day: $0))" }
                    result += " on \(ListFormatter().string(from: dayNames)!)"
                    return result
                }
            case .daysOfWeek(let weekdayOrdinal, let weekday):
                result += " on the \(weekdayOrdinal.name) \(weekday.name)"
                return result
            }
        case .yearly(frequency: let frequency, option: let option):
            var result = ""

            if frequency == 1 {
                result += "Repeat every year"
            } else {
                result += "Repeat every \(frequency) years"
            }

            switch option {
            case .daysOfYear(let months, _):
                let monthNames = months.map { DateFormatter().monthSymbols[$0-1] }
                result += " in \(ListFormatter().string(from: monthNames)!)"
                return result
            case .daysOfWeek(let months, let weekdayOrdinal, let weekday):
                let monthNames = months.map { DateFormatter().monthSymbols[$0-1] }
                result += " on the \(weekdayOrdinal.name) \(weekday.name)"
                result += " of \(ListFormatter().string(from: monthNames)!)"
                return result
            }
        }
    }

    private func daySuffix(day: Int) -> String {
        switch day {
          case 11...13:
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
