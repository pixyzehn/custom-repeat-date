import CustomRepeatDate
import Foundation

extension CustomRepeatDateOption {
    var name: String {
        switch self {
        case let .daily(frequency):
            if frequency == 1 {
                return NSLocalizedString("event_every_day", comment: "")
            } else {
                return String(format: NSLocalizedString("event_every_x_days", comment: ""), "\(frequency)")
            }

        case let .weekly(frequency: frequency, weekdays: weekdays):
            let weekdaysList = ListFormatter.localizedString(byJoining: weekdays.map(\.name))

            if frequency == 1 {
                return String(format: NSLocalizedString("event_every_week_on", comment: ""), weekdaysList)
            } else {
                return String(format: NSLocalizedString("event_every_x_weeks_on", comment: ""), "\(frequency)", weekdaysList)
            }

        case let .monthly(frequency: frequency, option: option):
            switch option {
            case let .daysOfMonth(days):
                if days.count == 1 {
                    if frequency == 1 {
                        return NSLocalizedString("event_every_month", comment: "")
                    } else {
                        return String(format: NSLocalizedString("event_every_x_months", comment: ""), "\(frequency)")
                    }
                } else {
                    let dayNames = days.map { daySuffix(day: $0) }
                    let dayNamesList = ListFormatter.localizedString(byJoining: dayNames)

                    if frequency == 1 {
                        return String(format: NSLocalizedString("event_every_month_on", comment: ""), dayNamesList)
                    } else {
                        return String(format: NSLocalizedString("event_every_x_months_on", comment: ""), "\(frequency)", dayNamesList)
                    }
                }
            case let .daysOfWeek(weekdayOrdinal, weekday):
                if frequency == 1 {
                    return String(format: NSLocalizedString("event_every_month_on_the", comment: ""), weekdayOrdinal.name, weekday.name)
                } else {
                    return String(format: NSLocalizedString("event_every_x_months_on_the", comment: ""), "\(frequency)", weekdayOrdinal.name, weekday.name)
                }
            }

        case let .yearly(frequency: frequency, option: option):
            switch option {
            case let .daysOfYear(months):
                let monthNames = months.map { DateFormatter().monthSymbols[$0 - 1] }
                let monthNamesList = ListFormatter.localizedString(byJoining: monthNames)

                if frequency == 1 {
                    return String(format: NSLocalizedString("evnet_every_year_in", comment: ""), monthNamesList)
                } else {
                    return String(format: NSLocalizedString("evnet_every_x_years_in", comment: ""), "\(frequency)", monthNamesList)
                }
            case let .daysOfWeek(months, weekdayOrdinal, weekday):
                let monthNames = months.map { DateFormatter().monthSymbols[$0 - 1] }
                let monthNamesList = ListFormatter.localizedString(byJoining: monthNames)

                if frequency == 1 {
                    return String(format: NSLocalizedString("evnet_every_year_on", comment: ""), weekdayOrdinal.name, weekday.name, monthNamesList)
                } else {
                    return String(format: NSLocalizedString("evnet_every_x_years_on", comment: ""), "\(frequency)", weekdayOrdinal.name, weekday.name, monthNamesList)
                }
            }
        }
    }

    private func daySuffix(day: Int) -> String {
        if day == CustomRepeatDateOption.MonthlyOption.lastDay {
            return NSLocalizedString("last_day", comment: "")
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        numberFormatter.locale = Locale.current
        return numberFormatter.string(for: day)!
    }
}
