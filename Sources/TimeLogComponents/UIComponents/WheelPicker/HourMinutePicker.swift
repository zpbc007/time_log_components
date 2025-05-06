//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/11/6.
//

import SwiftUI

struct HourMinutePicker: View {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter
    }()
    
    @Binding var selection: Date
    
    @State private var showPicker = false
    
    private var selectedString: String {
        Self.formatter.string(from: selection)
    }
    
    var body: some View {
        Text(selectedString)
            .foregroundStyle(showPicker ? Color.accentColor : Color(UIColor.label))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onTapGesture {
                showPicker.toggle()
            }
            .popover(isPresented: $showPicker) {
                Popover(selection: $selection)
                    .presentationCompactAdaptation(.popover)
            }
    }
}

extension HourMinutePicker {
    struct Popover: UIViewRepresentable {
        let selection: Binding<Date>
        
        func makeUIView(context: Context) -> UIPickerView {
            let pickerView = UIPickerView(frame: .zero)
            pickerView.translatesAutoresizingMaskIntoConstraints = false
            pickerView.delegate = context.coordinator
            pickerView.dataSource = context.coordinator
            
            let initHour = selection.wrappedValue.hour
            let initMinute = selection.wrappedValue.minute
            pickerView.selectRow(initHour, inComponent: 0, animated: false)
            pickerView.selectRow(initMinute, inComponent: 1, animated: false)
            
            return pickerView
        }
        
        func updateUIView(_ uiView: UIPickerView, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(selection: selection)
        }
        
        final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
            let selection: Binding<Date>
            let hours: [Int]
            let minutes: [Int]
            
            init(selection: Binding<Date>) {
                self.selection = selection
                self.hours = Array(stride(from: 0, through: 23, by: 1))
                self.minutes = Array(stride(from: 0, through: 59, by: 1))
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
                
                selection.wrappedValue = selection.wrappedValue
                    .setHourAndMinute(hour: hours[hourIndex], minute: minutes[minuteIndex])
            }
        }
    }
}

#Preview("HourMinutePicker") {
    struct Playground: View {
        @State var selected: Date = .now
        
        var body: some View {
            VStack {
                Spacer()
                
                HStack {
                    Text("选中时间")
                    
                    Spacer()
                    
                    HourMinutePicker(selection: $selected)
                }
                
                HStack {
                    Text("选中时间")
                    
                    Spacer()
                    
                    HourMinutePicker(selection: $selected)
                }
            }.padding()
        }
    }
    
    return Playground()
}

#Preview("Popover") {
    struct Playground: View {
        @State var selected: Date = .now
        
        var body: some View {
            VStack {
                Text("selection: \(selected)")
                HourMinutePicker.Popover(selection: $selected)
            }
            
        }
    }
    
    return Playground()
}
