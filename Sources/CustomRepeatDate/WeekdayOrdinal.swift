import Foundation

public enum WeekdayOrdinal: Int, CaseIterable, Codable {
    case first = 1
    case second = 2
    case third = 3
    case fourth = 4
    case fifth = 5
    case last = -1
}

extension WeekdayOrdinal: Comparable {
    public static func < (lhs: WeekdayOrdinal, rhs: WeekdayOrdinal) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
