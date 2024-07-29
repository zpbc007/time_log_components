//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/29.
//

import SwiftUI

struct WeekWheelPicker: View {
    let startDate: Date
    let endDate: Date
    // 所选择的周的周一
    @Binding var selectedWeekStartDate: Date
    
    @State private var showPicker = false
    
    private var weeks: [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 周一为一周中的第一天
        
        var weekArr: [Date] = []
        var currentDate = startDate.thisWeekFirstMonday
        
        while currentDate <= endDate {
            weekArr.append(currentDate)
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
        
        return weekArr
    }
    
    private var selectedWeekString: String {
        formatWeek(selectedWeekStartDate, dateFormat: "MM.dd")
    }
    
    private func formatWeek(_ weekStartDate: Date, dateFormat: String = "MM月dd日") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let weekEndDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate)!
        
        return "\(dateFormatter.string(from: weekStartDate))-\(dateFormatter.string(from: weekEndDate))"
    }
    
    var body: some View {
        Text(selectedWeekString)
            .foregroundStyle(showPicker ? .blue : .primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onTapGesture {
                showPicker.toggle()
            }
            .popover(isPresented: $showPicker, content: {
                Picker("Week", selection: $selectedWeekStartDate) {
                    ForEach(weeks, id: \.self) { week in
                        Text(formatWeek(week))
                    }
                }
                .pickerStyle(.wheel)
                .presentationCompactAdaptation(.popover)
            })
    }
}

#Preview {
    struct WeekWheelPicker_Playground: View {
        @State private var selectedWeekStartDate = Date.now.thisWeekFirstMonday
        
        var body: some View {
            WeekWheelPicker(
                startDate: Calendar.current.date(byAdding: .weekOfYear, value: -10, to: Date.now)!,
                endDate: Date.now,
                selectedWeekStartDate: $selectedWeekStartDate
            )
        }
    }
    
    return WeekWheelPicker_Playground()
}
