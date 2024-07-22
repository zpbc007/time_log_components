//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/22.
//

import SwiftUI
import IdentifiedCollections

public struct AnalyzeDayPage: View {
    let date: Date
    let totalTime: Int
    let maxTime: Int
    let maxTimeName: String
    let pipeChartValues: PipeChart.Values
    let lineChartValues: IdentifiedArrayOf<LineChart.Value>
    
    public init(
        date: Date,
        totalTime: Int,
        maxTime: Int,
        maxTimeName: String,
        pipeChartValues: PipeChart.Values,
        lineChartValues: IdentifiedArrayOf<LineChart.Value>
    ) {
        self.date = date
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
                    type: .day,
                    totalTime: totalTime,
                    maxTime: maxTime,
                    maxTimeName: maxTimeName
                )
            }
            
            if (!pipeChartValues.items.isEmpty) {
                Section("四象限") {
                    PipeChart(values: pipeChartValues)
                }
            }
            
            if (!lineChartValues.isEmpty) {
                Section("明细") {
                    LineChart(values: lineChartValues)
                }
            }
        }
    }
}

#Preview {
    AnalyzeDayPage(
        date: .now,
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
