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

        guard let startOfWeek = Calendar.current.date(
            from: Calendar.current.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: self
            )
        ) else {
            return result
        }

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
    
    public func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = format

        return formatter.string(from: self)
    }
    
    public var todayStartPoint: Date {
        Calendar.current.startOfDay(for: self)
    }
}
