//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/23.
//

import SwiftUI

public struct TodayTarget: View {
    let comment: String
    
    public init(comment: String) {
        self.comment = comment
    }
    
    public var body: some View {
        Group {
            if comment.isEmpty {
                HStack {
                    Spacer()
                    Image(systemName: "plus.app.fill")
                    Text("设置今日目标")
                    Spacer()
                }
            } else {
                RichTextViewer(content: comment)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview("long") {
    let comment = "{\"ops\":[{\"attributes\":{\"bold\":true},\"insert\":\"今天的目标是：\"},{\"insert\":\"\\n完成今日目标的开发\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"给菲打个视频\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"}]}"
    
    return TodayTarget(comment: comment).padding()
}

#Preview("short") {
    let comment = "{\"ops\":[{\"attributes\":{\"bold\":true},\"insert\":\"今天的目标是：\"},{\"insert\":\"\\n完成今日目标的开发\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"给菲打个视频\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"}]}"
    
    return TodayTarget(comment: comment).padding()
}

#Preview("empty") {
    VStack(spacing: 0) {
        Text("123")
        
        TodayTarget(comment: "")
            .padding()
        
        Text("456")
    }
    
}
