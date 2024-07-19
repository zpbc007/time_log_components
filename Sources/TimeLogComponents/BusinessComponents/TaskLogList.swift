//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import SwiftUI

public struct TaskLogList: View {
    let rows: [TaskLogCellViewState]
    let onCellTapped: (TimeLine.State) -> Void
    
    public init(
        rows: [TaskLogCellViewState],
        onCellTapped: @escaping (TimeLine.State) -> Void
    ) {
        self.rows = rows
        self.onCellTapped = onCellTapped
    }
    
    public var body: some View {
        if rows.isEmpty {
            VStack {
                Spacer()
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text("无记录数据")
                        
                    Spacer()
                }
                
                Spacer()
            }
        } else {
            List {
                VStack(alignment: .leading) {
                    ForEach(rows) { taskLogState in
                        if let timeLineState = taskLogState.timeLineState {
                            TimeLine(timeLineState)
                                .listRowSeparator(.hidden)
                                .onTapGesture {
                                    onCellTapped(timeLineState)
                                }
                            
                            HStack {
                                VDashedLine.RealLine()
                                    .frame(height: VDashedLine.EndTimeMinHeight)
                                Spacer()
                            }.padding(.leading, 25)
                        }
                        
                        if let dashedLineState = taskLogState.dashedLineState {
                            VDashedLine.WithDate(date: dashedLineState.date)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
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
    ]) { cell in
        print("cell tapped: \(cell.id)")
    }
}

#Preview("无数据") {
    TaskLogList(rows: []) { cell in
        print("cell tapped: \(cell.id)")
    }
}
