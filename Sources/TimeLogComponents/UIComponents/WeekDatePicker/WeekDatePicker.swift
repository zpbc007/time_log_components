//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/4.
//

import SwiftUI
import Foundation

public struct WeekDatePicker: View {
    let calendar: Calendar
    let showIndicatorDays: Set<Date>
    let activeColor: Color
    let indicatorColor: Color
    
    @Binding var date: Date
    @State private var page: Int = 0
    
    public init(
        calendar: Calendar,
        showIndicatorDays: Set<Date>,
        date: Binding<Date>,
        activeColor: Color,
        indicatorColor: Color
    ) {
        self.calendar = calendar
        self.activeColor = activeColor
        self.indicatorColor = indicatorColor
        self.showIndicatorDays = showIndicatorDays
        self._date = date
    }
    
    private func calculatePageDate(_ page: Int, isFirst: Bool) -> Date {
        calendar.date(
            byAdding: .day,
            value: page * 7 + (isFirst ? 0 : 6),
            to: Date.now.weekFirstDay(calendar: calendar)
        )!
    }
    
    private func calculateDatePage(_ date: Date) -> Int {
        let components = calendar.dateComponents(
            [.day],
            from: date,
            to: .now.weekFirstDay(calendar: calendar)
        )
        
        guard let days = components.day else {
            return 0
        }
        
        return -Int((Double(days) / Double(7)).rounded(.up))
    }
    
    private func calculatePageDays(_ page: Int) -> [WeekView.DateInfo] {
        let pageDate = calculatePageDate(page, isFirst: true)
        
        return pageDate.weekDays(calendar: calendar).map { date in
            .init(
                day: date,
                disabled: date > .now,
                bottomColor: showIndicatorDays.contains(date) ? indicatorColor : nil
            )
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            InfiniteTab(
                width: geometry.size.width,
                maxPage: 0, // 不能选择未来的时间
                page: $page
            ) { page in
                WeekView(
                    activeColor: activeColor,
                    today: .now.todayStartPoint,
                    days: calculatePageDays(page),
                    date: $date.animation(.easeOut)
                )
            }
        }.onChange(of: date) { oldValue, newValue in
            let newPage = calculateDatePage(newValue)
            if newPage != page {
                page = newPage
            }
        }.onChange(of: page) { oldValue, newValue in
            let newPageDate = calculatePageDate(newValue, isFirst: newValue >= oldValue)
            // 在同一个周
            if date.isSame(day: newPageDate, calendar: calendar, [.year, .weekOfYear]) {
                return
            }
            if newPageDate != date {
                date = newPageDate
            }
        }
    }
}

#Preview {
    struct Playground: View {
        @State
        private var date = Calendar.current.startOfDay(for: Date.now)
        private var calendar: Calendar = {
            var calendar = Calendar.current
//            calendar.firstWeekday = 2 // 周一为一周中的第一天
            return calendar
        }()
        
        var dateString: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            
            return dateFormatter.string(from: date)
        }
        
        var showIndicatorDays: Set<Date> {
            .init(
                self.date.weekDays().enumerated()
                    .filter({ (index, day) in
                        index % 2 == 0
                    })
                    .map({ (_, day) in
                        day
                    })
            )
        }
        
        var body: some View {
            VStack {
                HStack {
                    Text("SelectedDay: \(dateString)")
                        .font(.title)
                        .bold()
                    Spacer()
                    Button("Today") {
                        date = calendar.startOfDay(for: Date.now)
                    }
                }.padding(.horizontal)                
                
                WeekDatePicker(
                    calendar: calendar,
                    showIndicatorDays: showIndicatorDays,
                    date: $date,
                    activeColor: .accentColor,
                    indicatorColor: .green
                ).frame(height: 90)
                
                HStack {
                    Text("Content")
                }.background(.green)
                
                Spacer()
            }
        }
    }
    
    return Playground()
}
