import CustomRepeatDate
import Foundation

extension WeekdayOrdinal {
    var name: String {
        switch self {
        case .first: return "first"
        case .second: return "second"
        case .third: return "third"
        case .fourth: return "fourth"
        case .fifth: return "fifth"
        }
    }
}
