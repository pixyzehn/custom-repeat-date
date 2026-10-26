import CustomRepeatDate
import SwiftUI

struct PickerView: UIViewRepresentable {
    var data: [[String]]

    enum Component: Int {
        case weekdayOrdinal = 0
        case weekday = 1
    }

    @Binding var selectedWeekdayOrdinal: WeekdayOrdinal
    @Binding var selectedWeekday: Weekday

    func makeCoordinator() -> PickerView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<PickerView>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<PickerView>) {
        context.coordinator.parent = self
        view.reloadAllComponents()
        if data.indices.contains(Component.weekdayOrdinal.rawValue),
           let index = WeekdayOrdinal.allCases.firstIndex(of: selectedWeekdayOrdinal),
           data[Component.weekdayOrdinal.rawValue].indices.contains(index) {
            view.selectRow(index, inComponent: Component.weekdayOrdinal.rawValue, animated: false)
        }

        if data.indices.contains(Component.weekday.rawValue),
           let index = Weekday.allCases.firstIndex(of: selectedWeekday),
           data[Component.weekday.rawValue].indices.contains(index) {
            view.selectRow(index, inComponent: Component.weekday.rawValue, animated: false)
        }
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: PickerView

        init(_ pickerView: PickerView) {
            parent = pickerView
        }

        func numberOfComponents(in _: UIPickerView) -> Int {
            parent.data.count
        }

        func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            guard parent.data.indices.contains(component) else { return 0 }
            return parent.data[component].count
        }

        func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            guard parent.data.indices.contains(component),
                  parent.data[component].indices.contains(row) else { return nil }
            return parent.data[component][row]
        }

        func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            guard parent.data.indices.contains(component),
                  parent.data[component].indices.contains(row),
                  let component = Component(rawValue: component) else {
                return
            }

            switch component {
            case .weekdayOrdinal:
                guard WeekdayOrdinal.allCases.indices.contains(row) else { return }
                parent.selectedWeekdayOrdinal = WeekdayOrdinal.allCases[row]
            case .weekday:
                guard Weekday.allCases.indices.contains(row) else { return }
                parent.selectedWeekday = Weekday.allCases[row]
            }
        }
    }
}
