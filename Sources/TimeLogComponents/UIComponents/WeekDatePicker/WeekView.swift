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
        let today: Date
        let days: [DateInfo]
        @Binding var date: Date
        
        var body: some View {
            HStack {
                ForEach(days) { weekDay in
                    VStack {
                        Text(weekDay.day.toString(format: "EEE"))
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .frame(maxWidth:.infinity)
                        
                        ZStack {
                            HStack{
                                Spacer()
                                    .frame(width: 5)
                                Circle()
                                    .frame(width: 30)
                                    .foregroundColor(weekDay.day == date ? .accentColor : .clear)
                                Spacer()
                                    .frame(width: 5)
                            }
                            
                            Text(weekDay.day.toString(format: "d"))
                                .font(.system(size: 16))
                                .monospaced()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(getDateFontColor(info: weekDay))
                        }
                        
                        Circle()
                            .frame(width: 8)
                            .offset(y: -4)
                            .foregroundColor(weekDay.bottomColor ?? .clear)
                    }.onTapGesture {
                        if !weekDay.disabled {
                            date = weekDay.day
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
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
