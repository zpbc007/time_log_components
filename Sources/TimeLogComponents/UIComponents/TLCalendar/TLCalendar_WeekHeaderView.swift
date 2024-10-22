//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/16.
//

import SwiftUI

extension TLCalendar {
    struct WeekHeader: View {
        let weekDays: [Date]
        
        init(calendar: Calendar) {
            weekDays = Date.now.weekDays(calendar: calendar)
        }
        
        var body: some View {
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day.toString(format: "EEE"))
                        .fontWeight(.light)
                        .frame(maxWidth:.infinity)
                }
            }
        }
    }
}


#Preview {
    TLCalendar.WeekHeader(calendar: .current)
}
