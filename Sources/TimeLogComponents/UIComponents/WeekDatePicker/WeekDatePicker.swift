//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/4.
//

import SwiftUI
import Foundation

public struct WeekDatePicker: View {
    let indicatorColor: Color
    let showIndicatorDays: Set<Date>
    
    @Binding var date: Date
    @State private var page: Int = 0
    
    public init(
        indicatorColor: Color,
        showIndicatorDays: Set<Date>,
        date: Binding<Date>
    ) {
        self.indicatorColor = indicatorColor
        self.showIndicatorDays = showIndicatorDays
        self._date = date
    }
    
    private func calculatePageFirstDate(_ page: Int) -> Date {
        Calendar.current.date(
            byAdding: .day,
            value: page * 7,
            to: Date.now.weekFirstDay(calendar: .current)
        )!
    }
    
    private func calculateDatePage(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents(
            [.day],
            from: date,
            to: .now.weekFirstDay(calendar: .current)
        )
        
        guard let days = components.day else {
            return 0
        }
        
        return -Int((Double(days) / Double(7)).rounded(.up))
    }
    
    private func calculatePageDays(_ page: Int) -> [WeekView.DateInfo] {
        let pageDate = calculatePageFirstDate(page)
        
        return pageDate.weekDays().map { date in
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
            let newPageDate = calculatePageFirstDate(newValue)
            // 在同一个周
            if date.isSame(day: newPageDate, [.year, .month, .weekOfYear]) {
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
        @State var date = Calendar.current.startOfDay(for: Date.now)
        
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
                    Spacer()
                    Button("Today") {
                        date = Calendar.current.startOfDay(for: Date.now)
                    }
                }
                
                WeekDatePicker(
                    indicatorColor: .green,
                    showIndicatorDays: showIndicatorDays,
                    date: $date
                ).frame(height: 120)
                
                HStack {
                    Text("Content")
                }
                
                Spacer()
            }
        }
    }
    
    return Playground()
}
