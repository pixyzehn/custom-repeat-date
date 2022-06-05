import Foundation

enum Frequency: CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly

    var name: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    func everyName(count: Int) -> String {
        switch self {
        case .daily: return count > 1 ? "\(count) days" : "Day"
        case .weekly: return count > 1 ? "\(count) weeks" : "Week"
        case .monthly: return count > 1 ? "\(count) months" : "Month"
        case .yearly: return count > 1 ? "\(count) years" : "Year"
        }
    }
}
