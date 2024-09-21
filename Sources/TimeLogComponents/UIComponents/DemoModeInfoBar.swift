//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/9/19.
//

import SwiftUI

public struct DemoModeInfoBar: View {
    let bgColor: Color
    let fontColor: Color
    let buttonFontColor: Color
    let onExitTapped: () -> Void
    
    public init(
        bgColor: Color,
        fontColor: Color,
        buttonFontColor: Color, 
        onExitTapped: @escaping () -> Void
    ) {
        self.bgColor = bgColor
        self.fontColor = fontColor
        self.buttonFontColor = buttonFontColor
        self.onExitTapped = onExitTapped
    }
    
    public var body: some View {
        HStack {
            Text("当前为演示模式")
            
            Spacer()
            
            Button(action: onExitTapped) {
                Text("退出")
                    .foregroundStyle(buttonFontColor)
            }
        }
        .foregroundStyle(fontColor)
        .padding()
        .background(
            bgColor,
            in: RoundedRectangle(cornerRadius: 10)
        )
    }
}

#Preview {
    DemoModeInfoBar(
        bgColor: .purple,
        fontColor: .white,
        buttonFontColor: .blue
    ) {
        print("退出！")
    }
}
