//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/11/6.
//

import SwiftUI

struct HourMinutePicker: UIViewRepresentable {
    let selection: Binding<PickerValue>
    
    func makeUIView(context: Context) -> UIPickerView {
        let pickerView = UIPickerView(frame: .zero)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        return pickerView
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selection: selection)
    }
    
    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        let selection: Binding<PickerValue>
        let hours: [Int]
        let minutes: [Int]
        
        init(selection: Binding<PickerValue>) {
            self.selection = selection
            self.hours = Array(stride(from: 0, through: 23, by: 1))
            self.minutes = Array(stride(from: 0, through: 55, by: 5))
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return component == 0 ? hours.count : minutes.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if component == 0 {
                return "\(hours[row])时"
            } else {
                return "\(minutes[row])分"
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let hourIndex = pickerView.selectedRow(inComponent: 0)
            let minuteIndex = pickerView.selectedRow(inComponent: 1)
            selection.wrappedValue = .init(hour: hours[hourIndex], minute: minutes[minuteIndex])
        }
    }
}

extension HourMinutePicker {
    struct PickerValue: Equatable {
        let hour: Int
        let minute: Int
    }
}

#Preview {
    struct Playground: View {
        @State var selected: HourMinutePicker.PickerValue = .init(hour: 0, minute: 0)
        
        var body: some View {
            HourMinutePicker(selection: $selected)
        }
    }
    
    return Playground()
}
