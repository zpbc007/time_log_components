//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/4.
//

import SwiftUI

public struct WeekDatePicker: View {
    let indicatorColor: Color
    let showIndicatorDays: Set<Date>
    
    @Binding var date: Date
    @Binding var page: Int
    
    public init(
        indicatorColor: Color,
        showIndicatorDays: Set<Date>,
        date: Binding<Date>,
        page: Binding<Int>
    ) {
        self.indicatorColor = indicatorColor
        self.showIndicatorDays = showIndicatorDays
        self._date = date
        self._page = page
    }
    
    private func calculatePageDate(_ page: Int) -> Date {
        Calendar.current.date(
            byAdding: .day,
            value: page * 7,
            to: Date.now.todayStartPoint
        )!
    }
    
    private func calculatePageDays(_ page: Int) -> [WeekView.DateInfo] {
        let pageDate = calculatePageDate(page)
        
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
                page: $page
            ) { page in
                VStack {
                    WeekView(
                        today: .now.todayStartPoint,
                        days: calculatePageDays(page),
                        date: $date.animation(.easeOut)
                    )
                }
            }
        }
    }
}

#Preview {
    struct Playground: View {
        @State var date = Calendar.current.startOfDay(for: Date.now)
        @State var page = 0
        
        var dateString: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            
            return dateFormatter.string(from: date)
        }
        
        func calculatePageDate(_ page: Int) -> Date {
            Calendar.current.date(
                byAdding: .day,
                value: page * 7,
                to: Date.now.todayStartPoint
            )!
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
                        page = 0
                    }
                }
                
                WeekDatePicker(
                    indicatorColor: .green,
                    showIndicatorDays: showIndicatorDays,
                    date: $date,
                    page: $page
                ).frame(height: 80, alignment: .top)
                
                HStack {
                    Text("Content")
                }
                
                Spacer()
            }
            .onChange(of: page) { _, newValue in
                // 回到当天
                if (page == 0
                    && self.date == Date.now.todayStartPoint
                ) {
                    return
                }
                self.date = calculatePageDate(newValue)
            }
        }
    }
    
    return Playground()
}
