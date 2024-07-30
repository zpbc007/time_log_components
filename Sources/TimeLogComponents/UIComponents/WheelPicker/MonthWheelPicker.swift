//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/30.
//

import SwiftUI

public struct MonthWheelPicker: View {
    let startDate: Date
    let endDate: Date
    @Binding var selectedMonthStartDate: Date
    
    @State private var showPicker = false
    
    public init(
        startDate: Date, 
        endDate: Date,
        selectedMonthStartDate: Binding<Date>
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self._selectedMonthStartDate = selectedMonthStartDate
    }
    
    private var months: [Date] {
        var result: [Date] = []
        
        let endDate = endDate.thisMonthEndPoint
        var currentDate = startDate.thisMonthStartPoint
        while currentDate <= endDate {
            result.append(currentDate)
            currentDate = currentDate.add(byAdding: .month, 1)
        }
        
        return result
    }
    
    private var selectedMonthString: String {
        formatMonth(selectedMonthStartDate)
    }
    
    private func formatMonth(_ monthStartDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月"
        
        return dateFormatter.string(from: monthStartDate)
    }
    
    public var body: some View {
        Text(selectedMonthString)
            .foregroundStyle(showPicker ? .blue : .primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onTapGesture {
                showPicker.toggle()
            }
            .popover(isPresented: $showPicker, content: {
                Picker("Month", selection: $selectedMonthStartDate) {
                    ForEach(months, id: \.self) { month in
                        Text(formatMonth(month))
                    }
                }
                .pickerStyle(.wheel)
                .presentationCompactAdaptation(.popover)
            })
    }
}

#Preview {
    struct MonthWheelPickerPlayground: View {
        @State var selectedMonthStartDate: Date = Date.now.thisMonthStartPoint
        
        var body: some View {
            MonthWheelPicker(
                startDate: Date.from(year: 2020, month: 1),
                endDate: Date.now,
                selectedMonthStartDate: $selectedMonthStartDate
            )
        }
    }
    
    return MonthWheelPickerPlayground()
}
