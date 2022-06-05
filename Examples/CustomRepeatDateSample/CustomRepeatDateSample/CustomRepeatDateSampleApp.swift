import SwiftUI

@main
struct CustomRepeatDateSampleApp: App {
    var body: some Scene {
        WindowGroup {
            CustomRepeatDateView(date: .constant(Date()))
        }
    }
}
