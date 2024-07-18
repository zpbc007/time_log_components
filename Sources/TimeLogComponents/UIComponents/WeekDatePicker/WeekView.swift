//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/4.
//
import SwiftUI

extension WeekDatePicker {
    struct WeekView: View {
        struct DateInfo: Equatable, Identifiable {
            let day: Date
            let disabled: Bool
            let bottomColor: Color?
            
            var id: Date {
                day
            }
        }
        let activeColor: Color
        let today: Date
        let days: [DateInfo]
        @Binding var date: Date
        
        var body: some View {
            HStack(alignment: .top) {
                ForEach(days) { weekDay in
                    VStack {
                        Text(weekDay.day.toString(format: "EEE"))
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .frame(maxWidth:.infinity)
                        
                        ZStack {
                            Circle()
                                .padding(.horizontal, 5)
                                .foregroundColor(weekDay.day == date ? activeColor : .clear)
                            
                            Text(weekDay.day.toString(format: "d"))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(getDateFontColor(info: weekDay))
                        }
                        
                        if let bottomColor = weekDay.bottomColor {
                            Circle()
                                .frame(width: 8)
                                .offset(y: -4)
                                .foregroundColor(bottomColor)
                        }
                        
                    }.onTapGesture {
                        if !weekDay.disabled {
                            date = weekDay.day
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        
        private func getDateFontColor(info: DateInfo) -> Color {
            // 选中状态
            if info.day == date {
                return .white
            }
            
            // 今日
            if info.day == today {
                return .accentColor
            }
            
            // 禁用
            if info.disabled {
                return .secondary
            }
            
            return .primary
        }
    }
}

#Preview {
    struct Playground: View {
        @State var selectedDate = Calendar.current.startOfDay(for: Date())
        
        var days: [WeekDatePicker.WeekView.DateInfo] {
            selectedDate.weekDays().enumerated().map { (index, day) in
                .init(
                    day: day,
                    disabled: index % 2 == 0,
                    bottomColor: index % 2 == 1 ? .green : nil
                )
            }
        }
        
        var body: some View {
            VStack {
                Text("Header")
                WeekDatePicker.WeekView(
                    activeColor: .accentColor,
                    today: .now.todayStartPoint,
                    days: days,
                    date: $selectedDate
                )
                Text("Content")
                Spacer()
            }
            
        }
    }
    
    return Playground()
}
