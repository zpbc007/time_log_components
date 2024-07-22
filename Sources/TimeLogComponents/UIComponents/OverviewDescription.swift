//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/22.
//

import SwiftUI

struct OverviewDescription: View {
    enum DurationType: String {
        case day = "今日"
        case week = "本周"
        case month = "本月"
        case year = "今年"
    }
    let type: DurationType
    let totalTime: Int
    let maxTime: Int
    let maxTimeName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("\(type.rawValue)共记录")
                Text(totalTime, format: .number)
                    .font(.largeTitle)
                Text("次")
            }
            
            HStack {
                Text(maxTimeName)
                    .bold()
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text("记录了")
                Text(maxTime, format: .number)
                    .font(.largeTitle)
                Text("次")
            }
        }
    }
}

#Preview {
    OverviewDescription(
        type: .day,
        totalTime: 10,
        maxTime: 20,
        maxTimeName: "yyy任务"
    )
}
