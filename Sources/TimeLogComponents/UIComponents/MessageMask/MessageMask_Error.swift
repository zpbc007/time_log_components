//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/5/28.
//

import SwiftUI

extension MessageMask {
    struct ErrorMessageView: View {
        let info: MessageMaskDataProvider.ErrorInfo
        let buttonFontColor: Color
        let buttonBGColor: Color
        let retryAction: () -> Void
        
        var body: some View {
            VStack {
                Spacer()
                
                HStack {
                    Image(systemName: "exclamationmark")
                        .foregroundStyle(.red)
                    
                    Text(info.title)
                }
                .padding(.bottom)
                .font(.largeTitle)
                
                Text(info.msg)
                    .padding(.bottom)
                
                Button(action: retryAction, label: {
                    Label("重试", systemImage: "arrow.clockwise")
                })
                .bold()
                .font(.title3)
                .padding()
                .background(buttonBGColor, in: RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(buttonFontColor)
                
                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    MessageMask<EmptyView>.ErrorMessageView(
        info: .init(
            title: "获取数据失败",
            msg: "获取远端数据失败，请恢复网络连接后重试"
        ),
        buttonFontColor: .white,
        buttonBGColor: .black
    ) {
        print("retry")
    }
}
