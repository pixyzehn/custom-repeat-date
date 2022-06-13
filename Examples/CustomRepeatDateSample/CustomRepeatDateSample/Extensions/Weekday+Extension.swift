import CustomRepeatDate
import Foundation

extension Weekday {
    var name: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .current
        return calendar.standaloneWeekdaySymbols[rawValue - 1]
    }
}
