//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/9/21.
//

import SwiftUI

public struct VerticalText: View {
    let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        VStack {
            ForEach(text.components(separatedBy: .whitespacesAndNewlines), id: \.self) { item in
                Text("\(item)")
            }
        }
    }
}

#Preview {
    VerticalText(text: "退 出 演 示 模 式")
}
