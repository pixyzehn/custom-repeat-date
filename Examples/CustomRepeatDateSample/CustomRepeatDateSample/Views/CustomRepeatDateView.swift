import CustomRepeatDate
import SwiftUI

struct CustomRepeatDateView: View {
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
    @State var selectedWeekdayOrdinalInMonthly: WeekdayOrdinal = .first
    @State var selectedWeekdayInMonthly: Weekday = .monday

    // Yearly
    @State var selectedMonthsOfYear: Set<Int> = [1]
    @State var isDaysOfWeekEnabled = false
    @State var selectedWeekdayOrdinalInYearly: WeekdayOrdinal = .first
    @State var selectedWeekdayInYearly: Weekday = .monday

    let allDaysOfWeek: [[String]] = [
        WeekdayOrdinal.allCases.map(\.name),
        Weekday.allCases.map(\.name),
    ]
    let allFrequencies = Frequency.allCases
    let lastDay = CustomRepeatDateOption.MonthlyOption.lastDay

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
                var days = Array(selectedDaysOfMonth).sorted()
                // Move the last day to the end
                if days.contains(lastDay) {
                    days.removeAll(where: { $0 == lastDay })
                    days.append(lastDay)
                }
                option = .monthly(frequency: frequency, option: .daysOfMonth(days: days))
            case .daysOfWeek:
                let weekdayOrdinal = selectedWeekdayOrdinalInMonthly
                let weekday = selectedWeekdayInMonthly
                option = .monthly(frequency: frequency, option: .daysOfWeek(weekdayOrdinal: weekdayOrdinal, weekday: weekday))
            }
        case .yearly:
            let months = Array(selectedMonthsOfYear).sorted()
            if isDaysOfWeekEnabled {
                let weekdayOrdinal = selectedWeekdayOrdinalInYearly
                let weekday = selectedWeekdayInYearly
                option = .yearly(frequency: frequency, option: .daysOfWeek(months: months, weekdayOrdinal: weekdayOrdinal, weekday: weekday))
            } else {
                option = .yearly(frequency: frequency, option: .daysOfYear(months: months))
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
        selectedWeekdayOrdinalInMonthly = .first
        selectedWeekdayInMonthly = .monday

        // Yearly
        selectedMonthsOfYear = [1]
        isDaysOfWeekEnabled = false
        selectedWeekdayOrdinalInYearly = .first
        selectedWeekdayInYearly = .monday
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: DemoView(option: $option)) {
                        Text("demo")
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
                            Text("frequency")
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
                            Text("every")
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
                                Text("each")
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
                                Text("on_the")
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
                                Divider()
                                    .frame(height: 1 / UIScreen.main.scale)
                                    .background(Color(uiColor: .systemGroupedBackground))
                                    .padding(0)
                                HStack {
                                    Spacer()
                                    Text("last_day")
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding()
                                .background(selectedDaysOfMonth.contains(lastDay) ? .blue : Color(uiColor: .secondarySystemGroupedBackground))
                                .onTapGesture {
                                    if selectedDaysOfMonth.contains(lastDay) {
                                        if selectedDaysOfMonth.count > 1 {
                                            selectedDaysOfMonth.remove(lastDay)
                                        }
                                    } else {
                                        selectedDaysOfMonth.insert(lastDay)
                                    }

                                    updateOption()
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        } else {
                            PickerView(
                                data: allDaysOfWeek,
                                selectedWeekdayOrdinal: $selectedWeekdayOrdinalInMonthly,
                                selectedWeekday: $selectedWeekdayInMonthly
                            )
                            .onChange(of: selectedWeekdayOrdinalInMonthly) { _ in
                                updateOption()
                            }
                            .onChange(of: selectedWeekdayInMonthly) { _ in
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
                        Toggle("days_of_week", isOn: $isDaysOfWeekEnabled)
                            .onChange(of: isDaysOfWeekEnabled) { _ in
                                updateOption()
                            }
                        if isDaysOfWeekEnabled {
                            PickerView(
                                data: allDaysOfWeek,
                                selectedWeekdayOrdinal: $selectedWeekdayOrdinalInYearly,
                                selectedWeekday: $selectedWeekdayInYearly
                            )
                            .onChange(of: selectedWeekdayOrdinalInYearly) { _ in
                                updateOption()
                            }
                            .onChange(of: selectedWeekdayInYearly) { _ in
                                updateOption()
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("custom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        reset()
                    }) {
                        Text("reset")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
