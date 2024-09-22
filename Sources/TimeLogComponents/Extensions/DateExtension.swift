//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/6/4.
//

import SwiftUI

extension Date {
    public static func from(year: Int, month: Int, day: Int = 1) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }
    
    public var todayStartPoint: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    public var todayEndPoint: Date {
        let calendar = Calendar.current
        let endOfDay = calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: self
        )
        return endOfDay ?? self
    }
    
    /// 当前周的周一（周一为当前周的第一天）
    public var thisWeekFirstMonday: Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 周一为一周中的第一天
        
        return self.weekFirstDay(calendar: calendar)
    }
    
    /// 获取 date 所在周的所有日期
    public func weekDays(calendar: Calendar = .current) -> [Date] {
        var result: [Date] = .init()
        let startOfWeek = self.weekFirstDay(calendar: calendar)

        (0...6).forEach { day in
            if let weekday = calendar.date(
                byAdding: .day,
                value: day,
                to: startOfWeek
            ) {
                result.append(weekday)
            }
        }

        return result
    }
    
    public var thisMonthStartPoint: Date {
        Date.from(year: self.year, month: self.month).todayStartPoint
    }
    
    public var thisMonthEndPoint: Date {
        let lastDay = Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 1
        
        return Date.from(year: self.year, month: self.month, day: lastDay).todayEndPoint
    }
    
    public func weekFirstDay(calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents(
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
    
    public func add(byAdding component: Calendar.Component = .day, _ value: Int) -> Date {
        Calendar.current.date(
            byAdding: component,
            value: value,
            to: self
        )!
    }
    
    public var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    public var year: Int {
        Calendar.current.component(.year, from: self)
    }
}
