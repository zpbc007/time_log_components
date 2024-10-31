//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import SwiftUI

public struct TaskLogList {
    static let BottomId = "bottom"
}

extension TaskLogList {
    public struct MainView<Header: View>: View {
        let rows: [TaskLogCellViewState]
        let disableTransition: Bool
        let scrollToBottom: Bool
        let header: () -> Header
        let onCellTapped: (TimeLine.CardState) -> Void
        
        public init(
            rows: [TaskLogList.TaskLogCellViewState],
            disableTransition: Bool,
            scrollToBottom: Bool = false,
            header: @escaping () -> Header,
            onCellTapped: @escaping (TimeLine.CardState) -> Void
        ) {
            self.rows = rows
            self.disableTransition = disableTransition
            self.scrollToBottom = scrollToBottom
            self.header = header
            self.onCellTapped = onCellTapped
        }
        
        public var body: some View {
            ScrollViewReader { proxy in
                ScrollView {
                    header()
                    
                    if rows.isEmpty {
                        self.EmptyRowView
                    } else {
                        LazyVStack(alignment: .leading) {
                            ForEach(rows) { taskLogState in
                                if let timeLineState = taskLogState.timeLineState {
                                    TimeLine(timeLineState)
                                        .id(timeLineState.id)
                                        .onTapGesture {
                                            onCellTapped(timeLineState)
                                        }
                                        .transition(
                                            disableTransition
                                                ? .identity
                                                : .asymmetric(
                                                    insertion: .move(edge: .trailing)
                                                        .combined(
                                                            with: .scale(scale: 0.1).animation(.bouncy)
                                                        ),
                                                    removal: .opacity
                                                )
                                        )
                                    
                                    HStack {
                                        TLLine.Vertical()
                                            .frame(height: TLLine.EndTimeMinHeight)
                                        Spacer()
                                    }.padding(.leading, 25)
                                }
                                
                                if let dashedLineState = taskLogState.dashedLineState {
                                    TLLine.WithDate(date: dashedLineState.date)
                                }
                            }
                        }
                    }
                    
                    HStack {}.frame(height: 60)
                        .background(.clear)
                        .id(TaskLogList.BottomId)
                }
                .onChange(of: scrollToBottom) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo(TaskLogList.BottomId, anchor: .bottom)
                    }
                }
            }
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

extension TaskLogList {
    public enum TaskLogCellViewState: Equatable, Identifiable {
        public struct DashedLineState: Equatable {
            private static let dateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY年MM月dd日"
                return formatter
            }()
            
            let date: Date
            let dateString: String
            
            public init(_ date: Date) {
                self.date = date
                self.dateString = Self.dateFormatter.string(from: date)
            }
        }
        
        case TimeLine(TimeLine.CardState)
        case DashedLine(DashedLineState)
        
        public var id: String {
            switch self {
            case .DashedLine(let state):
                return "DashedLine_\(state.dateString)"
            case .TimeLine(let state):
                return "TimeLine-\(state.id)"
            }
        }
        
        public var timeLineState: TimeLine.CardState? {
            switch self {
            case .TimeLine(let timeLineState):
                return timeLineState
            default:
                return nil
            }
        }
        
        public var dashedLineState: DashedLineState? {
            switch self {
            case .DashedLine(let dashedLineState):
                return dashedLineState
            default:
                return nil
            }
        }
    }
}

#Preview("正常") {
    TaskLogList.MainView(rows: [
        .DashedLine(.init(.now)),
        .TimeLine(.init(
            id: UUID().uuidString,
            startTime: .now.addingTimeInterval(-600),
            endTime: .now.addingTimeInterval(-180) ,
            title: "已结束任务",
            color: .blue
        )),
        .TimeLine(.init(
            id: UUID().uuidString,
            startTime: .now.addingTimeInterval(-600),
            endTime: .now.addingTimeInterval(-180) ,
            title: "超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title",
            color: .blue
        )),
        .TimeLine(.init(
            id: UUID().uuidString,
            startTime: .now,
            title: "未结束任务",
            color: .blue
        ))
    ], disableTransition: false, header: {
        Text("Header")
            .font(.title)
    }) { cell in
        print("cell tapped: \(cell.id)")
    }
}

#Preview("无数据") {
    TaskLogList.MainView(rows: [], disableTransition: false, header: {
        Text("Header")
            .font(.title)
    }) { cell in
        print("cell tapped: \(cell.id)")
    }
}

#Preview("动态") {
    struct Playground: View {
        @State private var rows: [TaskLogList.TaskLogCellViewState] = [
            .TimeLine(.init(
                id: UUID().uuidString,
                startTime: .now.addingTimeInterval(-600),
                endTime: .now.addingTimeInterval(-180) ,
                title: "已结束任务",
                color: .blue
            ))
        ]
        @State private var disableTransition = false
        @State private var scrollToBottom = false
        
        var body: some View {
            VStack {
                HStack {
                    Button("+") {
                        withAnimation {
                            scrollToBottom.toggle()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    rows.append(.TimeLine(.init(
                                        id: UUID().uuidString,
                                        startTime: .now,
                                        endTime: .now,
                                        title: "log-\(rows.count)",
                                        color: .init(
                                            uiColor: .init(
                                                red: .random(in: 0...1),
                                                green: .random(in: 0...1),
                                                blue: .random(in: 0...1),
                                                alpha: .random(in: 0...1)
                                            )
                                        )
                                    )))
                                    scrollToBottom.toggle()
                                }
                            }
                        }
                    }
                    
                    Button("-") {
                        withAnimation {
                            _ = rows.removeLast()
                        }
                    }
                    
                    Toggle("disableTransition", isOn: $disableTransition)
                }.padding()
                
                TaskLogList.MainView(
                    rows: rows,
                    disableTransition: disableTransition,
                    scrollToBottom: scrollToBottom,
                    header: {
                        Text("Header")
                            .font(.title)
                    }
                ) { _ in
                    
                }
            }
            
        }
    }
    
    return Playground()
}

#Preview("替换") {
    struct Playground: View {
        @State private var rows: [TaskLogList.TaskLogCellViewState] = []
        let first: TaskLogList.TaskLogCellViewState = .TimeLine(.init(
            id: UUID().uuidString,
            startTime: .now,
            endTime: .now,
            title: "log-first",
            color: .init(
                uiColor: .init(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    alpha: .random(in: 0...1)
                )
            )
        ))
        let second: TaskLogList.TaskLogCellViewState = .TimeLine(.init(
            id: UUID().uuidString,
            startTime: .now,
            endTime: .now,
            title: "log-second",
            color: .init(
                uiColor: .init(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    alpha: .random(in: 0...1)
                )
            )
        ))
        
        var body: some View {
            VStack {
                Button("toggle") {
                    withAnimation {
                        if rows.isEmpty {
                            rows = [first]
                        } else if rows.count == 1 {
                            rows = [first, second]
                        } else {
                            rows = []
                        }
                    }
                }
                
                TaskLogList.MainView(
                    rows: rows,
                    disableTransition: false,
                    header: {
                        Text("Header")
                            .font(.title)
                    }
                ) { _ in
                    
                }
            }
        }
    }
    
    return Playground()
}
