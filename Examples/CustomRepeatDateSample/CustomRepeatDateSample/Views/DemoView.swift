import CustomRepeatDate
import SwiftUI

struct DemoView: View {
    @Binding var option: CustomRepeatDateOption
    @State private var startDate = Date()
    @State private var result = [Date]()
    let calendar = Calendar(identifier: .gregorian)
    let numberOfGeneratedItems = 30

    func generate() {
        var result = [Date]()
        var date = startDate
        for _ in 0..<numberOfGeneratedItems {
            if let newDate = calendar.nextDate(after: date, option: option) {
                result.append(newDate)
                date = newDate
            }
        }

        withAnimation {
            self.result = result
        }
    }

    var body: some View {
        List {
            Section {
                DatePicker("Start Date", selection: $startDate)
            }
            Section {
                ForEach(0..<result.count, id: \.self) { i in
                    HStack {
                        Text("\(i + 1)")
                        Spacer()
                        Text(result[i].formatted(date: .long, time: .shortened))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Demo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    generate()
                }) {
                    Text("Generate")
                }
            }
        }
    }
}
