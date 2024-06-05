//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/6/4.
//

import SwiftUI

extension Date {
    /// 获取 date 所在周的所有日期
    public func weekDays() -> [Date] {
        var result: [Date] = .init()
        let startOfWeek = self.weekFirstDay(calendar: .current)

        (0...6).forEach { day in
            if let weekday = Calendar.current.date(
                byAdding: .day,
                value: day,
                to: startOfWeek
            ) {
                result.append(weekday)
            }
        }

        return result
    }
    
    public func weekFirstDay(calendar: Calendar) -> Date {
        calendar.date(
            from: Calendar.current.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: self
            )
        ) ?? self
    }
    
    public func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = format

        return formatter.string(from: self)
    }
    
    public var todayStartPoint: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    public func isSame(day: Date, _ components: Set<Calendar.Component> = [.year, .month, .day]) -> Bool {
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents(components, from: self)
        let dateComponents = calendar.dateComponents(components, from: day)
        
        for comp in components {
            guard
                let todayValue = todayComponents.value(for: comp),
                    let dateValue = dateComponents.value(for: comp)
            else {
                return false
            }
        
            if todayValue != dateValue {
                return false
            }
        }
        
        return true
    }
}
