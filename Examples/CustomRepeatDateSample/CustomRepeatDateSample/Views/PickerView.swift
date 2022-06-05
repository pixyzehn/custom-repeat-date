import SwiftUI

struct PickerView: UIViewRepresentable {
    var data: [[String]]
    @Binding var selections: [Int]

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
        for index in 0 ..< selections.count {
            view.selectRow(selections[index], inComponent: index, animated: false)
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
            parent.selections[component] = row
        }
    }
}
