//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/16.
//

import SwiftUI

struct TLCalendar: View {
    static let dayViewHeight: CGFloat = 35
    static let weekHeaderHeight: CGFloat = 30
    
    let foreground: Color
    let disabledForeground: Color
    let selectionForeground: Color
    let selectionBG: Color
    let calendar: Calendar
    @Binding var selected: Date?
    
    @State private var open = false
    @State private var page: Int = 0
    
    private var height: CGFloat {
        open ? Self.dayViewHeight * 6 : Self.dayViewHeight
    }
    
    var body: some View {
        VStack(spacing: 0) {
            WeekHeader(calendar: calendar)
                .frame(height: 30)
                .clipped()
                .border(.black)
            
            GeometryReader { geometry in
                InfiniteTab(
                    width: geometry.size.width,
    //                maxPage: 0, // 不能选择未来的时间
                    page: $page
                ) { pageNumber in
                    MonthView(
                        foreground: foreground,
                        disabledForeground: disabledForeground,
                        selectionForeground: selectionForeground,
                        selectionBG: selectionBG,
                        dayViewHeight: Self.dayViewHeight,
                        days: self.calculateMonthDays(pageNumber),
                        selected: pageNumber == page ? $selected : .constant(nil)
                    )
                    .offset(y: calculateOffsetByPage(page))
                    .clipped()
                }
            }
            .frame(height: height)
            .clipped()
        }
        .overlay(alignment: .bottom) {
            Button("toggle") {
                withAnimation {
                    open.toggle()
                }
            }.offset(y: 20)
        }
        .onChange(of: page) { oldValue, newValue in
            if open {
                selected = self.calculatePageFirstDateForMonth(
                    newValue, target: (selected, oldValue)
                )
            } else {
                selected = self.calculatePageFirstDateForWeek(
                    newValue,
                    target: (selected, oldValue)
                )
            }
        }
    }
    
    private func calculateOffsetByPage(_ page: Int) -> CGFloat {
        if open {
            return 0
        }
        
        return -CGFloat((selected?.weekIndexInMonth(calendar: calendar) ?? 0)) * Self.dayViewHeight
    }
    
    private func calculateWeekDays(_ page: Int) -> [(Date, Bool)] {
        self.calculatePageFirstDateForWeek(page)
            .weekDays(calendar: calendar)
            .map { date in
                (date, date > .now)
            }
    }
    
    private func calculateMonthDays(_ page: Int) -> [[(Date, Bool)]] {
        self.calculatePageFirstDateForMonth(page)
            .monthDaysByWeek(calendar: calendar)
            .map { weekDays in
                weekDays.map { date in
                    (date, date > .now)
                }
            }
    }
    
    private func calculatePageFirstDateForWeek(_ page: Int, target: (Date?, Int)? = nil) -> Date {
        guard let selected else {
            return .now
        }
        
        let targetDate = target?.0 ?? selected
        let targetPage = target?.1 ?? self.page
        
        return calendar.date(
            byAdding: .day,
            value: (page - targetPage) * 7,
            to: targetDate
        ) ?? .now
    }
    
    private func calculatePageFirstDateForMonth(_ page: Int, target: (Date?, Int)? = nil) -> Date {
        guard let selected else {
            return .now
        }
        
        let targetDate = target?.0 ?? selected
        let targetPage = target?.1 ?? self.page
        
        return calendar.date(
            byAdding: .month,
            value: page - targetPage,
            to: targetDate
        ) ?? .now
    }
}

#Preview {
    struct Playground: View {
        @State private var selected: Date? = .now
        
        var body: some View {
            VStack {
                if let selected {
                    Text("\(selected)")
                }
                
                TLCalendar(
                    foreground: .black,
                    disabledForeground: .gray,
                    selectionForeground: .white,
                    selectionBG: .green.opacity(0.6),
                    calendar: .current,
                    selected: $selected
                )
                
                Spacer()
            }
            
        }
    }
    
    return Playground()
}
