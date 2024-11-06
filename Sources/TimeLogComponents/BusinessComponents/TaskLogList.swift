//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import SwiftUI
import IdentifiedCollections

public struct TaskLogList {
    static let BottomId = "bottom"
}

extension TaskLogList {
    public struct MainView<Header: View>: View {
        let day: Date
        let rows: IdentifiedArrayOf<TimeLine.CardState>
        let timeLineStateRows: [TimeLine.TimeLineState]
        let disableTransition: Bool
        let latestEndTime: Date?
        let header: () -> Header
        let selectAction: (_ startHour: Int, _ startMinute: Int, _ endHour: Int, _ endMinute: Int) -> Void
        let onCellTapped: (TimeLine.CardState) -> Void
        
        public init(
            day: Date,
            rows: IdentifiedArrayOf<TimeLine.CardState>,
            disableTransition: Bool,
            latestEndTime: Date? = nil,
            header: @escaping () -> Header,
            selectAction: @escaping (_ startHour: Int, _ startMinute: Int, _ endHour: Int, _ endMinute: Int) -> Void,
            onCellTapped: @escaping (TimeLine.CardState) -> Void
        ) {
            self.day = day
            self.rows = rows
            self.disableTransition = disableTransition
            self.latestEndTime = latestEndTime
            self.header = header
            self.selectAction = selectAction
            self.onCellTapped = onCellTapped
            
            let start = day.todayStartPoint
            let end = day.todayEndPoint
            self.timeLineStateRows = rows.map({$0.toTimeLineState(start: start, end: end)})
        }
        
        public var body: some View {
            TimeLine.GridBGWithActive(
                oneMinuteHeight: 1.2,
                items: self.timeLineStateRows,
                latestHour: latestEndTime?.hour,
                disableTransition: disableTransition,
                header: header,
                content: { id, height in
                    if let state = rows[id: id] {
                        TimeLine.CardWithTag(state, height: height)
                            .onTapGesture(perform: {
                                onCellTapped(state)
                            })
                            .padding(.leading, 2)
                    }
                },
                selectAction: self.selectAction
            )
        }
        
        @ViewBuilder
        private var EmptyRowView: some View {
            VStack {
                Spacer()
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text("无记录数据")
                        
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}

#Preview("正常") {
    var tasks: [TimeLine.CardState] = Array(stride(from: 5, to: 61, by: 5)).reduce(into: []) { partialResult, duration in
        var startTime: Date
        if let last = partialResult.last {
            startTime = last.endTime.addingTimeInterval(5 * 60)
        } else {
            startTime = .now.todayStartPoint
        }
        
        partialResult.append(.init(
            id: UUID().uuidString,
            startTime: startTime,
            endTime: startTime.addingTimeInterval(duration * 60),
            title: "\(duration) min",
            color: .blue
        ))
    }
    
    tasks.append(.init(
        id: UUID().uuidString,
        startTime: .now.todayStartPoint.addingTimeInterval(60 * 60 * 8),
        endTime: .now.todayStartPoint.addingTimeInterval(60 * 60 * 8 + 60 * 5),
        title: "超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title",
        color: .red
    ))
    let rows: IdentifiedArrayOf<TimeLine.CardState> = .init(uniqueElements: tasks)
    
    return TaskLogList.MainView(
        day: .now.todayStartPoint,
        rows: rows,
        disableTransition: false,
        header: {
            Text("Header")
                .font(.title)
        }
    ) { startHour, startMinute, endHour, endMinute in
        print("select: start: \(startHour):\(startMinute), end: \(endHour):\(endMinute)")
    } onCellTapped: { cell in
        print("cell tapped: \(cell.id)")
    }
}

#Preview("无数据") {
    TaskLogList.MainView(
        day: .now, 
        rows: [],
        disableTransition: false,
        header: {
            Text("Header")
                .font(.title)
        }
    ) { startHour, startMinute, endHour, endMinute in
        print("select: start: \(startHour):\(startMinute), end: \(endHour):\(endMinute)")
    } onCellTapped: { cell in
        print("cell tapped: \(cell.id)")
    }
}

#Preview("动态") {
    struct Playground: View {
        @State private var rows: IdentifiedArrayOf<TimeLine.CardState> = .init(uniqueElements: [
            .init(
                id: UUID().uuidString,
                startTime: .now.todayStartPoint,
                endTime: .now.todayStartPoint.addingTimeInterval(TimeInterval(30 * 60)),
                title: "初始任务",
                color: .red
            )
        ])
        @State private var disableTransition = false
        @State private var latestEndTime: Date? = nil
        
        var body: some View {
            VStack {
                HStack {
                    Button("+") {
                        let startTime = rows.elements.last?.endTime.addingTimeInterval(5 * 60) ?? .now.todayStartPoint
                        let endTime = startTime.addingTimeInterval(30 * 60)
                        latestEndTime = endTime
                        
                        withAnimation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    rows.append(.init(
                                        id: UUID().uuidString,
                                        startTime: startTime,
                                        endTime: endTime,
                                        title: "log-\(rows.count)",
                                        color: .init(
                                            uiColor: .init(
                                                red: .random(in: 0...1),
                                                green: .random(in: 0...1),
                                                blue: .random(in: 0...1),
                                                alpha: .random(in: 0...1)
                                            )
                                        )
                                    ))
                                }
                            }
                        }
                    }
                    
                    Button("-") {
                        withAnimation {
//                            rows.removeLast()
                        }
                    }
                    
                    Toggle("disableTransition", isOn: $disableTransition)
                }.padding()
                
                TaskLogList.MainView(
                    day: .now,
                    rows: rows,
                    disableTransition: disableTransition,
                    latestEndTime: latestEndTime,
                    header: {
                        Text("Header")
                            .font(.title)
                    }
                ) { startHour, startMinute, endHour, endMinute in
                    print("select: start: \(startHour):\(startMinute), end: \(endHour):\(endMinute)")
                } onCellTapped: { cell in
                    print("cell tapped: \(cell.id)")
                }
            }
        }
    }
    
    return Playground()
}

#Preview("替换") {
    struct Playground: View {
        @State private var rows: IdentifiedArrayOf<TimeLine.CardState> = .init()
        let first: TimeLine.CardState = .init(
            id: UUID().uuidString,
            startTime: .now.todayStartPoint,
            endTime: .now.todayStartPoint.addingTimeInterval(30 * 60),
            title: "log-first",
            color: .init(
                uiColor: .init(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    alpha: .random(in: 0...1)
                )
            )
        )
        let second: TimeLine.CardState = .init(
            id: UUID().uuidString,
            startTime: .now.todayStartPoint.addingTimeInterval(60 * 60),
            endTime: .now.todayStartPoint.addingTimeInterval(120 * 60),
            title: "log-second",
            color: .init(
                uiColor: .init(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    alpha: .random(in: 0...1)
                )
            )
        )
        
        var body: some View {
            VStack {
                Button("toggle") {
                    withAnimation {
                        if rows.isEmpty {
                            rows = .init(uniqueElements: [first])
                        } else if rows.count == 1 {
                            rows = .init(uniqueElements: [first, second])
                        } else {
                            rows = .init()
                        }
                    }
                }
                
                TaskLogList.MainView(
                    day: .now,
                    rows: rows,
                    disableTransition: false,
                    header: {
                        Text("Header")
                            .font(.title)
                    }
                ) { startHour, startMinute, endHour, endMinute in
                    print("select: start: \(startHour):\(startMinute), end: \(endHour):\(endMinute)")
                } onCellTapped: { cell in
                    print("cell tapped: \(cell.id)")
                }
            }
        }
    }
    
    return Playground()
}
