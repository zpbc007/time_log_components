//
//  DateExtensionTests.swift
//  
//
//  Created by zhaopeng on 2024/10/17.
//

import XCTest
@testable 
import TimeLogComponents

final class DateExtensionTests: XCTestCase {
    func testMonthDaysByWeek() {
        let formatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            return formatter
        }()
        let date = Date.from(year: 2024, month: 2)
        let monthDays = date.monthDaysByWeek()
        let expectResult: [[String]] = [
            ["2024-01-28","2024-01-29","2024-01-30","2024-01-31","2024-02-01","2024-02-02","2024-02-03"],
            ["2024-02-04","2024-02-05","2024-02-06","2024-02-07","2024-02-08","2024-02-09","2024-02-10"],
            ["2024-02-11","2024-02-12","2024-02-13","2024-02-14","2024-02-15","2024-02-16","2024-02-17"],
            ["2024-02-18","2024-02-19","2024-02-20","2024-02-21","2024-02-22","2024-02-23","2024-02-24"],
            ["2024-02-25","2024-02-26","2024-02-27","2024-02-28","2024-02-29","2024-03-01","2024-03-02"],
            ["2024-03-03","2024-03-04","2024-03-05","2024-03-06","2024-03-07","2024-03-08","2024-03-09"]
        ]
        
        monthDays.enumerated().forEach { week in
            week.element.enumerated().forEach { day in
                let expectString = expectResult[week.offset][day.offset]
                let targetString = formatter.string(from: day.element)
                
                XCTAssert(targetString == expectString)
            }
        }
    }
    
    // 使用自定义的第一天
    func testWeekIndexInMonthDifferentCalendar() {
        let date1 = Date.from(year: 2024, month: 9, day: 2)
        
        // 默认周日为第一天
        XCTAssert(date1.weekIndexInMonth() == 0)
        
        // 周一为第一天
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        XCTAssert(date1.weekIndexInMonth(calendar: calendar) == 1)
        
        let date2 = Date.from(year: 2025, month: 2, day: 2)
        XCTAssert(date2.weekIndexInMonth() == 1)
        
        // 周六为第一天
        calendar.firstWeekday = 7
        XCTAssert(date2.weekIndexInMonth(calendar: calendar) == 0)
    }
}
