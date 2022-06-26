import Foundation

enum Frequency: CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly

    var name: String {
        switch self {
        case .daily: return NSLocalizedString("daily", comment: "")
        case .weekly: return NSLocalizedString("weekly", comment: "")
        case .monthly: return NSLocalizedString("monthly", comment: "")
        case .yearly: return NSLocalizedString("yearly", comment: "")
        }
    }

    func everyName(count: Int) -> String {
        switch self {
        case .daily: return String(format: NSLocalizedString("every_name_daily", comment: ""), count)
        case .weekly: return String(format: NSLocalizedString("every_name_weekly", comment: ""), count)
        case .monthly: return String(format: NSLocalizedString("every_name_monthly", comment: ""), count)
        case .yearly: return String(format: NSLocalizedString("every_name_yearly", comment: ""), count)
        }
    }
}
