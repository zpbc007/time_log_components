//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/22.
//

import SwiftUI
import IdentifiedCollections

public struct AnalyzeDayPage: View {
    let type: OverviewDescription.DurationType
    let totalTime: Int
    let recordDuration: TimeInterval
    let blackHoleDuration: TimeInterval
    let pipeChartValues: PipeChart.Values?
    let lineChartValues: IdentifiedArrayOf<LineChart.Value>?
    
    public init(
        type: OverviewDescription.DurationType,
        totalTime: Int,
        recordDuration: TimeInterval,
        blackHoleDuration: TimeInterval,
        pipeChartValues: PipeChart.Values?,
        lineChartValues: IdentifiedArrayOf<LineChart.Value>?
    ) {
        self.type = type
        self.totalTime = totalTime
        self.recordDuration = recordDuration
        self.blackHoleDuration = blackHoleDuration
        self.pipeChartValues = pipeChartValues
        self.lineChartValues = lineChartValues
    }
    
    public var body: some View {
        List {
            Section {
                OverviewDescription(
                    type: type,
                    totalTime: totalTime,
                    recordDuration: recordDuration,
                    blackHoleDuration: blackHoleDuration
                )
            }
            
            Section("人生时间") {
                if let pipeChartValues {
                    PipeChart(values: pipeChartValues)
                } else {
                    HStack {
                        Spacer()
                        Text("暂无数据，快去记录吧")
                            .font(.caption)
                        Spacer()
                    }
                }
                
                if let lineChartValues {
                    LineChart(values: lineChartValues)
                }
            }
        }
    }
}

#Preview {
    AnalyzeDayPage(
        type: .day,
        totalTime: 10,
        recordDuration: 2680200,
        blackHoleDuration: 2680200,
        pipeChartValues: .init(.init(uniqueElements: [
            .init(duration: 36000 , label: "生存", color: .init(hexString: "#FDE7BBFF")),
            .init(duration: 28800, label: "工作", color: .init(hexString: "#81BFDAFF")),
            .init(duration: 14400, label: "自由", color: .init(hexString: "#9EDF9CFF"))
        ])),
        lineChartValues: .init(
            uniqueElements: [
                .init(label: "自由", count: 1, duration: 500, color: .init(hexString: "#9EDF9CFF")),
                .init(label: "工作", count: 1, duration: 100, color: .init(hexString: "#81BFDAFF")),
                .init(label: "生存", count: 1, duration: 50, color: .init(hexString: "#FDE7BBFF"))
            ]
        )
    )
}

#Preview("Empty") {
    AnalyzeDayPage(
        type: .day,
        totalTime: 10,
        recordDuration: 2680200,
        blackHoleDuration: 2680200,
        pipeChartValues: nil,
        lineChartValues: nil
    )
}
