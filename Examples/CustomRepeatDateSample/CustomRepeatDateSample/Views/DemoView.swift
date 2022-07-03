import CustomRepeatDate
import SwiftUI

struct DemoView: View {
    @Binding var option: CustomRepeatDateOption
    @State var startDate = Date()
    @State var result = [Date]()
    let calendar = Calendar(identifier: .gregorian)
    let numberOfGeneratedItems = 30

    func generate() {
        var result = [Date]()
        var date = startDate
        for _ in 0 ..< numberOfGeneratedItems {
            if let newDate = calendar.nextDate(after: date, option: option) {
                result.append(newDate)
                date = newDate
            }
        }

        withAnimation {
            self.result = result
        }
    }

    func shortWeekdaySymbol(date: Date) -> String {
        let rawValue = calendar.component(.weekday, from: date)
        return calendar.shortStandaloneWeekdaySymbols[rawValue - 1]
    }

    var body: some View {
        List {
            Section {
                DatePicker("start_date", selection: $startDate)
            }
            Section {
                ForEach(0 ..< result.count, id: \.self) { i in
                    HStack {
                        Text("\(i + 1)")
                        Spacer()
                        Text(result[i].formatted(date: .long, time: .shortened))
                        Text(shortWeekdaySymbol(date: result[i]))
                    }
                    .font(.system(.caption2, design: .monospaced))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("demo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    generate()
                }) {
                    Text("generate")
                }
            }
        }
    }
}
