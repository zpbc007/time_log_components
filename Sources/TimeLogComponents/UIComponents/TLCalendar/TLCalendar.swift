//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/16.
//

import SwiftUI

public struct TLCalendar: View {
    static let dayViewHeight: CGFloat = 35
    static let weekHeaderHeight: CGFloat = 30
    
    let foreground: Color
    let disabledForeground: Color
    let selectionForeground: Color
    let selectionBG: Color
    let calendar: Calendar
    @Binding var selected: Date
    
    public init(
        foreground: Color,
        disabledForeground: Color,
        selectionForeground: Color,
        selectionBG: Color,
        calendar: Calendar,
        selected: Binding<Date>
    ) {
        self.foreground = foreground
        self.disabledForeground = disabledForeground
        self.selectionForeground = selectionForeground
        self.selectionBG = selectionBG
        self.calendar = calendar
        self._selected = selected
    }
    
    @State private var open = false
    @State private var page: Int = 0
    
    private var height: CGFloat {
        open ? Self.dayViewHeight * 6 : Self.dayViewHeight
    }
    
    private var maxPage: Int {
        let isSameMonth = selected.month == Date.now.month
        
        // 可以翻到下一页
        if !isSameMonth {
            return page + 1
        }
        
        if open {
            return page
        } else {
            if selected.weekIndexInMonth(calendar: calendar) == Date.now.weekIndexInMonth(calendar: calendar) {
                return page
            } else {
                return page + 1
            }
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            WeekHeader(calendar: calendar)
                .frame(height: 30)
                .clipped()
            
            GeometryReader { geometry in
                InfiniteTab(
                    width: geometry.size.width,
                    maxPage: maxPage, // 不能选择未来的时间
                    page: $page
                ) { pageNumber in
                    MonthView(
                        foreground: foreground,
                        disabledForeground: disabledForeground,
                        selectionForeground: selectionForeground,
                        selectionBG: selectionBG,
                        dayViewHeight: Self.dayViewHeight,
                        days: self.calculateMonthDays(pageNumber),
                        selected: pageNumber == page ? curPageSelected : .constant(.distantPast)
                    )
                    .offset(y: calculateOffsetByPage(page))
                    .clipped()
                }
            }
            .frame(height: height)
            .clipped()
            
            ToggleButton
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
    
    private var curPageSelected: Binding<Date> {
        .init(get: { selected }) { newDate in
            if newDate > .now {
                return
            }

            selected = newDate
        }
    }
    
    @ViewBuilder
    private var ToggleButton: some View {
        Button {
            withAnimation {
                open.toggle()
            }
        } label: {
            Image(systemName: open ? "chevron.compact.up" : "chevron.compact.down")
                .padding()
        }
    }
    
    private func calculateOffsetByPage(_ page: Int) -> CGFloat {
        if open {
            return 0
        }
        
        return -CGFloat((selected.weekIndexInMonth(calendar: calendar))) * Self.dayViewHeight
    }
    
    private func calculateWeekDays(_ page: Int) -> [(Date, Bool)] {
        self.calculatePageFirstDateForWeek(page)
            .weekDays(calendar: calendar)
            .map { date in
                (date, date > .now)
            }
    }
    
    private func calculateMonthDays(_ page: Int) -> [[(Date, Bool)]] {
        let pageDate = self.calculatePageFirstDateForMonth(page)
        let targetMonth = pageDate.month
        
        return pageDate
            .monthDaysByWeek(calendar: calendar)
            .map { weekDays in
                weekDays.map { date in
                    (date, date.month != targetMonth || date > .now)
                }
            }
    }
    
    private func calculatePageFirstDateForWeek(_ page: Int, target: (Date?, Int)? = nil) -> Date {
        let targetDate = target?.0 ?? selected
        let targetPage = target?.1 ?? self.page
        
        return calendar.date(
            byAdding: .day,
            value: (page - targetPage) * 7,
            to: targetDate
        ) ?? .now
    }
    
    private func calculatePageFirstDateForMonth(_ page: Int, target: (Date?, Int)? = nil) -> Date {
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
        @State private var selected: Date = .now
        
        var body: some View {
            VStack {
                Text("\(selected)")
                
                TLCalendar(
                    foreground: .black,
                    disabledForeground: .gray,
                    selectionForeground: .white,
                    selectionBG: .green.opacity(0.6),
                    calendar: .current,
                    selected: $selected
                )
                .border(.black)
                
                Spacer()
            }
            
        }
    }
    
    return Playground()
}
