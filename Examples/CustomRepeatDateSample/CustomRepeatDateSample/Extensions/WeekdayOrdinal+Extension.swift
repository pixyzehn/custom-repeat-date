import CustomRepeatDate
import Foundation

extension WeekdayOrdinal {
    var name: String {
        switch self {
        case .first: return NSLocalizedString("first", comment: "")
        case .second: return NSLocalizedString("second", comment: "")
        case .third: return NSLocalizedString("third", comment: "")
        case .fourth: return NSLocalizedString("fourth", comment: "")
        case .fifth: return NSLocalizedString("fifth", comment: "")
        }
    }
}
