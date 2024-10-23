//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/16.
//

import SwiftUI

extension TLCalendar {
    struct WeekView: View {
        let foreground: Color
        let disabledForeground: Color
        let selectionForeground: Color
        let selectionBG: Color
        let dayViewHeight: CGFloat
        let days: [(Date, Bool)]
        @Binding var selected: Date
                
        var body: some View {
            HStack(spacing: 0) {
                ForEach(days, id: \.0) { (day, disabled) in
                    TLCalendar.DayView(
                        date: day,
                        foreground: foreground,
                        disabledForeground: disabledForeground,
                        selectionForeground: selectionForeground,
                        selectionBG: selectionBG,
                        disabled: disabled,
                        selected: $selected
                    )
                    .frame(height: dayViewHeight)
                }
            }
        }
        
        @ViewBuilder
        private func dayView(_ day: Date) -> some View {
            Text(day.toString(format: "d"))
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var selected: Date = .now
        
        var body: some View {
            TLCalendar.WeekView(
                foreground: .black,
                disabledForeground: .gray,
                selectionForeground: .white,
                selectionBG: .green.opacity(0.5),
                dayViewHeight: 35,
                days: Date.now.weekDays().enumerated().map({ item in
                    (item.element, item.offset > 3 ? true : false)
                }),
                selected: $selected
            )
            .padding()
            .animation(.easeInOut, value: selected)
        }
    }

    return Playground()
}
