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

    func updateUIView(_ view: UIPickerView, context _: UIViewRepresentableContext<PickerView>) {
        if let index = WeekdayOrdinal.allCases.firstIndex(of: selectedWeekdayOrdinal) {
            view.selectRow(index, inComponent: Component.weekdayOrdinal.rawValue, animated: false)
        }

        if let index = Weekday.allCases.firstIndex(of: selectedWeekday) {
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
            parent.data[component].count
        }

        func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            parent.data[component][row]
        }

        func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            guard let component = Component(rawValue: component) else {
                return
            }

            switch component {
            case .weekdayOrdinal:
                parent.selectedWeekdayOrdinal = WeekdayOrdinal.allCases[row]
            case .weekday:
                parent.selectedWeekday = Weekday.allCases[row]
            }
        }
    }
}
