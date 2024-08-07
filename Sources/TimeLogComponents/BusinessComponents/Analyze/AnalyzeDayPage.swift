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
    let maxTime: Int?
    let maxTimeName: String?
    let pipeChartValues: PipeChart.Values?
    let lineChartValues: IdentifiedArrayOf<LineChart.Value>?
    
    public init(
        type: OverviewDescription.DurationType,
        totalTime: Int,
        maxTime: Int?,
        maxTimeName: String?,
        pipeChartValues: PipeChart.Values?,
        lineChartValues: IdentifiedArrayOf<LineChart.Value>?
    ) {
        self.type = type
        self.totalTime = totalTime
        self.maxTime = maxTime
        self.maxTimeName = maxTimeName
        self.pipeChartValues = pipeChartValues
        self.lineChartValues = lineChartValues
    }
    
    public var body: some View {
        List {
            Section {
                OverviewDescription(
                    type: type,
                    totalTime: totalTime,
                    maxTime: maxTime,
                    maxTimeName: maxTimeName
                )
            }
            
            Section("四象限") {
                if let pipeChartValues {
                    PipeChart(values: pipeChartValues)
                } else {
                    HStack {
                        Spacer()
                        Text("添加标签为 \"四象限\" 的任务")
                            .font(.caption)
                        Spacer()
                    }
                }
            }
            
            Section("明细") {
                if let lineChartValues {
                    LineChart(values: lineChartValues)
                } else {
                    HStack {
                        Spacer()
                        Text("无数据")
                            .font(.caption)
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    AnalyzeDayPage(
        type: .day,
        totalTime: 10,
        maxTime: 20,
        maxTimeName: "yyy任务",
        pipeChartValues: .init(.init(uniqueElements: [
            .init(duration: 3600, label: "重要紧急", color: .red),
            .init(duration: 1800, label: "重要不紧急", color: .blue),
            .init(duration: 3000, label: "不重要不紧急", color: .black),
            .init(duration: 3000, label: "不重要紧急", color: .green)
        ])),
        lineChartValues: .init(
            uniqueElements: [
                .init(label: "重要紧急", count: 1, duration: 50, color: .red),
                .init(label: "重要不紧急", count: 1, duration: 100, color: .blue),
                .init(label: "不重要不紧急", count: 1, duration: 500, color: .green),
                .init(label: "不重要紧急", count: 1, duration: 500, color: .green)
            ]
        )
    )
}

#Preview("Empty") {
    AnalyzeDayPage(
        type: .day,
        totalTime: 10,
        maxTime: nil,
        maxTimeName: nil,
        pipeChartValues: nil,
        lineChartValues: nil
    )
}
