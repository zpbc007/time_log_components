//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/9/27.
//

import SwiftUI

struct RoundedButton: View {
    let title: String
    let bgColor: Color
    let borderColor: Color
    let action: () -> Void
    
    init(
        _ title: String,
        bgColor: Color = .clear,
        borderColor: Color = .clear,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.bgColor = bgColor
        self.borderColor = borderColor
        self.action = action
    }
    
    var body: some View {
        Button (
            action: action,
            label: {
                Text(title)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(bgColor)
                            .strokeBorder(borderColor, lineWidth: 2)
                    )
                    .minimumScaleFactor(0.5)
                    .scaledToFit()
            }
        )
    }
}

#Preview {
    VStack {
        RoundedButton("Button") { }
        RoundedButton("Button", bgColor: .gray) { }
        RoundedButton("Button", borderColor: .blue) { }
        RoundedButton("Button", bgColor: .green, borderColor: .blue) {}
    }
    
}
