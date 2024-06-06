//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/6.
//

import SwiftUI

public struct TodayOverview: View {
    static let formatter: DateComponentsFormatter = {
        let formater = DateComponentsFormatter()
        formater.allowedUnits = [.hour, .minute, .second]
        formater.unitsStyle = .abbreviated
        
        return formater
    }()
    
    public init(recordTime: Int, recordSeconds: TimeInterval) {
        self.recordTime = recordTime
        self.recordSeconds = recordSeconds
    }
    
    // 记录次数
    let recordTime: Int
    // 已记录时间
    let recordSeconds: TimeInterval
    
    private var recordSecondsString: String? {
        Self.formatter.string(from: recordSeconds)
    }
    
    public var body: some View {
        VStack {
            ProgressView(value: recordSeconds, total: 24 * 60 * 60)
                .tint(.green)
                .scaleEffect(x: 1, y: 4, anchor: .center)
            
            HStack {
                Text("已记录")
                Text(recordTime, format: .number)
                    .bold()
                Text("次,")
                
                if let recordSecondsString {
                    Text("共")
                    Text(recordSecondsString)
                        .bold()
                }
                
                Spacer()
            }
            .padding(.top, 10)
            .font(.caption)
        }
    }
}

#Preview {
    TodayOverview(
        recordTime: 20,
        recordSeconds: 10 * 60 * 60
    )
}
