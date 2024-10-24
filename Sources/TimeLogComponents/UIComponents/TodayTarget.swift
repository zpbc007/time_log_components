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
        RichTextViewer(content: comment)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .frame(maxHeight: 180)
    }
}

#Preview {
    struct Playground: View {
        @State private var comment: String = "{\"ops\":[{\"attributes\":{\"bold\":true},\"insert\":\"今天的目标是：\"},{\"insert\":\"\\n完成今日目标的开发\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"给菲打个视频\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"}]}"
        
        var body: some View {
            VStack {
                TodayTarget(comment: comment)
            }.padding()
        }
    }
    
    return Playground()
}
