//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/16.
//

import SwiftUI

extension TLCalendar {
    struct MonthView: View {
        let foreground: Color
        let disabledForeground: Color
        let selectionForeground: Color
        let selectionBG: Color
        let dayViewHeight: CGFloat
        let days: [[(Date, Bool)]]
        @Binding var selected: Date?
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(days, id: \.first?.0) { weekDays in
                    TLCalendar.WeekView(
                        foreground: foreground,
                        disabledForeground: disabledForeground,
                        selectionForeground: selectionForeground,
                        selectionBG: selectionBG,
                        dayViewHeight: dayViewHeight,
                        days: weekDays,
                        selected: $selected
                    )
                }
            }
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var selected: Date? = .now
        
        var body: some View {
            TLCalendar.MonthView(
                foreground: .black,
                disabledForeground: .gray,
                selectionForeground: .white,
                selectionBG: .green.opacity(0.8),
                dayViewHeight: 40,
                days: Date.now.monthDaysByWeek().map({ weekDays in
                    weekDays.map { day in
                        (day, !day.isSame(day: .now, calendar: .current, [.month]))
                    }
                }),
                selected: $selected
            ).animation(.easeInOut, value: selected)
        }
    }
    
    return Playground()
}
