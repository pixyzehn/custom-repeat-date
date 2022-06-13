import CustomRepeatDate
import SwiftUI

struct CustomRepeatDateView: View {
    @Binding var date: Date
    @State var option: CustomRepeatDateOption = .daily(frequency: 1)

    @State var isFrequencySelection = false
    @State var isEverySelection = false

    // Top
    @State var selectedFrequency = Frequency.daily
    @State var selectedEvery = 1

    // Weekly
    @State var selectedWeekdays: Set<Weekday> = [.sunday]

    // Monthly
    enum MonthlyType {
        case daysOfMonth
        case daysOfWeek
    }

    @State var selectedMonthlyType: MonthlyType = .daysOfMonth
    @State var selectedDaysOfMonth: Set<Int> = [1]
    @State var selectedDaysOfWeekInMonthly: [Int] = [0, 0]

    // Yearly
    @State var selectedMonthsOfYear: Set<Int> = [1]
    @State var isDaysOfWeekEnabled = false
    @State var selectedDaysOfWeekInYearly: [Int] = [0, 0]

    let allDaysOfWeek: [[String]] = [
        WeekdayOrdinal.allCases.map { $0.name },
        Weekday.allCases.map { $0.name },
    ]
    let allFrequencies = Frequency.allCases

    func updateOption() {
        let frequency = selectedEvery

        switch selectedFrequency {
        case .daily:
            option = .daily(frequency: frequency)
        case .weekly:
            let weekdays = Array(selectedWeekdays).sorted()
            option = .weekly(frequency: frequency, weekdays: weekdays)
        case .monthly:
            switch selectedMonthlyType {
            case .daysOfMonth:
                let days = Array(selectedDaysOfMonth).sorted()
                option = .monthly(frequency: frequency, option: .daysOfMonth(days: days))
            case .daysOfWeek:
                let weekdayOrdinal = WeekdayOrdinal(rawValue: selectedDaysOfWeekInMonthly[0] + 1) ?? .first
                let weekday = Weekday(rawValue: selectedDaysOfWeekInMonthly[1] + 1) ?? .sunday
                option = .monthly(frequency: frequency, option: .daysOfWeek(weekdayOrdinal: weekdayOrdinal, weekday: weekday))
            }
        case .yearly:
            let months = Array(selectedMonthsOfYear).sorted()
            if isDaysOfWeekEnabled {
                let weekdayOrdinal = WeekdayOrdinal(rawValue: selectedDaysOfWeekInYearly[0] + 1) ?? .first
                let weekday = Weekday(rawValue: selectedDaysOfWeekInYearly[1] + 1) ?? .sunday
                option = .yearly(frequency: frequency, option: .daysOfWeek(months: months, weekdayOrdinal: weekdayOrdinal, weekday: weekday))
            } else {
                let day = Calendar.current.component(.day, from: date)
                option = .yearly(frequency: frequency, option: .daysOfYear(months: months, day: day))
            }
        }
    }

    func reset() {
        option = .daily(frequency: 1)

        isFrequencySelection = false
        isEverySelection = false

        // Top
        selectedFrequency = .daily
        selectedEvery = 1

        // Weekly
        selectedWeekdays = [.sunday]

        // Monthly
        selectedMonthlyType = .daysOfMonth
        selectedDaysOfMonth = [1]
        selectedDaysOfWeekInMonthly = [1, 1]

        // Yearly
        selectedMonthsOfYear = [1]
        isDaysOfWeekEnabled = false
        selectedDaysOfWeekInYearly = [1, 1]
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: DemoView(option: $option)) {
                        Text("Demo")
                    }
                }
                Section(footer:
                    Text(option.name)
                        .fixedSize(horizontal: false, vertical: true) // Prevent text from truncating in some cases
                ) {
                    Button(action: {
                        withAnimation {
                            isFrequencySelection.toggle()
                        }
                    }) {
                        HStack {
                            Text("Frequency")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(selectedFrequency.name)
                                .foregroundColor(.accentColor)
                        }
                    }
                    if isFrequencySelection {
                        Picker("", selection: $selectedFrequency) {
                            ForEach(allFrequencies, id: \.self) {
                                Text($0.name)
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: selectedFrequency) { _ in
                            updateOption()
                        }
                    }
                    Button(action: {
                        withAnimation {
                            isEverySelection.toggle()
                        }
                    }) {
                        HStack {
                            Text("Every")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(selectedFrequency.everyName(count: selectedEvery))
                                .foregroundColor(.accentColor)
                        }
                    }
                    if isEverySelection {
                        Picker("", selection: $selectedEvery) {
                            ForEach(1 ... 999, id: \.self) {
                                Text("\($0)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: selectedEvery) { _ in
                            updateOption()
                        }
                    }
                }
                Section {
                    if selectedFrequency == .weekly {
                        ForEach(Weekday.allCases, id: \.self) { weekday in
                            Button(action: {
                                if selectedWeekdays.contains(weekday) {
                                    if selectedWeekdays.count > 1 {
                                        selectedWeekdays.remove(weekday)
                                    }
                                } else {
                                    selectedWeekdays.insert(weekday)
                                }

                                updateOption()
                            }) {
                                HStack {
                                    Text(weekday.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedWeekdays.contains(weekday) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } else if selectedFrequency == .monthly {
                        Button(action: {
                            selectedMonthlyType = .daysOfMonth
                            updateOption()
                        }) {
                            HStack {
                                Text("Each")
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedMonthlyType == .daysOfMonth {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button(action: {
                            selectedMonthlyType = .daysOfWeek
                            updateOption()
                        }) {
                            HStack {
                                Text("On the...")
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedMonthlyType == .daysOfWeek {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        if selectedMonthlyType == .daysOfMonth {
                            VStack(spacing: 0) {
                                Divider()
                                    .frame(height: 1 / UIScreen.main.scale)
                                    .background(Color(uiColor: .systemGroupedBackground))
                                    .padding(0)
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 4), spacing: 1), count: 7), spacing: 1) {
                                    ForEach(1 ... 31, id: \.self) { index in
                                        ZStack {
                                            Rectangle()
                                                .foregroundColor(selectedDaysOfMonth.contains(index) ? .blue : Color(uiColor: .secondarySystemGroupedBackground))
                                                .aspectRatio(1, contentMode: .fill)
                                            Text("\(index)")
                                                .foregroundColor(.primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .onTapGesture {
                                            if selectedDaysOfMonth.contains(index) {
                                                if selectedDaysOfMonth.count > 1 {
                                                    selectedDaysOfMonth.remove(index)
                                                }
                                            } else {
                                                selectedDaysOfMonth.insert(index)
                                            }

                                            updateOption()
                                        }
                                    }
                                }
                                .background(Color(uiColor: .systemGroupedBackground))
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        } else {
                            PickerView(data: allDaysOfWeek, selections: $selectedDaysOfWeekInMonthly)
                                .onChange(of: selectedDaysOfWeekInMonthly) { _ in
                                    updateOption()
                                }
                        }
                    } else if selectedFrequency == .yearly {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 4), spacing: 1), count: 4), spacing: 1) {
                            ForEach(1 ... 12, id: \.self) { index in
                                ZStack {
                                    Rectangle()
                                        .frame(height: 50)
                                        .foregroundColor(selectedMonthsOfYear.contains(index) ? .blue : Color(uiColor: .secondarySystemGroupedBackground))
                                        .aspectRatio(1, contentMode: .fill)
                                    Text(DateFormatter().shortMonthSymbols[index - 1])
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    if selectedMonthsOfYear.contains(index) {
                                        if selectedMonthsOfYear.count > 1 {
                                            selectedMonthsOfYear.remove(index)
                                        }
                                    } else {
                                        selectedMonthsOfYear.insert(index)
                                    }

                                    updateOption()
                                }
                            }
                        }
                        .background(Color(uiColor: .systemGroupedBackground))
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                    }
                }
                if selectedFrequency == .yearly {
                    Section {
                        Toggle("Days of Week", isOn: $isDaysOfWeekEnabled)
                            .onChange(of: isDaysOfWeekEnabled) { _ in
                                updateOption()
                            }
                        if isDaysOfWeekEnabled {
                            PickerView(data: allDaysOfWeek, selections: $selectedDaysOfWeekInYearly)
                                .onChange(of: selectedDaysOfWeekInYearly) { _ in
                                    updateOption()
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Custom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        reset()
                    }) {
                        Text("Reset")
                    }
                }
            }
        }
    }
}
