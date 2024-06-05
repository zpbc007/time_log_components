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
        List {
            ForEach(rows) { taskLogState in
                if let timeLineState = taskLogState.timeLineState {
                    TimeLine(timeLineState)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            onCellTapped(timeLineState)
                        }
                }
                
                if let dashedLineState = taskLogState.dashedLineState {
                    VDashedLine.WithDate(date: dashedLineState.date)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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

#Preview {
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
            startTime: .now,
            title: "未结束任务",
            color: .blue
        ))
    ]) { cell in
        print("cell tapped: \(cell.id)")
    }
}
