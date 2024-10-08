//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import SwiftUI

public struct TaskLogList: View {
    static let BottomId = "bottom"
    
    let rows: [TaskLogCellViewState]
    let onCellTapped: (TimeLine.State) -> Void
    let disableTransition: Bool
    
    public init(
        rows: [TaskLogCellViewState],
        disableTransition: Bool,
        onCellTapped: @escaping (TimeLine.State) -> Void
    ) {
        self.rows = rows
        self.disableTransition = disableTransition
        self.onCellTapped = onCellTapped
    }
    
    public var body: some View {
        Group {
            if rows.isEmpty {
                self.EmptyRowView
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
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
                                        VDashedLine.RealLine()
                                            .frame(height: VDashedLine.EndTimeMinHeight)
                                        Spacer()
                                    }.padding(.leading, 25)
                                }
                                
                                if let dashedLineState = taskLogState.dashedLineState {
                                    VDashedLine.WithDate(date: dashedLineState.date)
                                }
                            }
                        }
                        
                        HStack {}.frame(height: 80)
                            .background(.clear)
                            .id(Self.BottomId)
                    }
                    .onChange(of: rows) { oldValue, newValue in
                        withAnimation {
                            proxy.scrollTo(Self.BottomId, anchor: .bottom)
                        }
                    }
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
        
        case TimeLine(TimeLine.State)
        case DashedLine(DashedLineState)
        
        public var id: String {
            switch self {
            case .DashedLine(let state):
                return "DashedLine_\(state.dateString)"
            case .TimeLine(let state):
                return "TimeLine-\(state.id)"
            }
        }
        
        public var timeLineState: TimeLine.State? {
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
    TaskLogList(rows: [
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
    ], disableTransition: false) { cell in
        print("cell tapped: \(cell.id)")
    }
}

#Preview("无数据") {
    TaskLogList(rows: [], disableTransition: false) { cell in
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
        
        var body: some View {
            VStack {
                HStack {
                    Button("+") {
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
                        }
                    }
                    
                    Button("-") {
                        withAnimation {
                            _ = rows.removeLast()
                        }
                    }
                    
                    Toggle("disableTransition", isOn: $disableTransition)
                }.padding()
                
                TaskLogList(rows: rows, disableTransition: disableTransition) { _ in
                    
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
                
                TaskLogList(rows: rows, disableTransition: false) { _ in
                    
                }
            }
        }
    }
    
    return Playground()
}
