//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/22.
//

import SwiftUI

public struct OverviewDescription: View {
    public enum DurationType: String {
        case day = "今日"
        case week = "本周"
        case month = "本月"
    }
    
    let type: DurationType
    // 总记录次数
    let totalTime: Int
    // 总记录时长
    let recordDuration: TimeInterval
    // 黑洞时长
    let blackHoleDuration: TimeInterval
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var recordPercent: Double {
        return recordDuration + blackHoleDuration == 0
            ? 0
            : recordDuration / (recordDuration + blackHoleDuration)
    }
    
    private var recordDurationString: String {
        return self.formatInterval(self.recordDuration)
    }
    
    private var blackHoleDurationString: String {
        return self.formatInterval(self.blackHoleDuration)
            
    }
    
    private func formatInterval(_ interval: TimeInterval) -> String {
        Duration.seconds(interval)
            .formatted(.units(
                allowed: .init([.days, .hours, .minutes]),
                width: .narrow,
                maximumUnitCount: 3
            ))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("\(type.rawValue)共记录")
                Text(totalTime, format: .number)
                    .font(.title2)
                Text("次")
            }
            
            VStack(spacing: 5) {
                HStack {
                    Text("记录时长")
                    Text(recordDurationString)
                        .font(.title2)
                    Spacer()
                    Text(
                        recordPercent,
                        format: .percent.precision(.fractionLength(2))
                    )
                }
                
                ProgressView(value: recordPercent)
            }
        }
    }
}

#Preview {
    OverviewDescription(
        type: .day,
        totalTime: 10,
        recordDuration: 2680200,
        blackHoleDuration: 2680200
    )
}

#Preview("Empty") {
    OverviewDescription(
        type: .day,
        totalTime: 10,
        recordDuration: 0,
        blackHoleDuration: 0
    )
}
