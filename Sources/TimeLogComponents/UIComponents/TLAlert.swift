//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/11/7.
//

import SwiftUI

public struct TLAlert: View {
    let state: AlertState
    let cancelAction: () -> Void
    let confirmAction: () -> Void
    
    public init(
        state: AlertState,
        cancelAction: @escaping () -> Void,
        confirmAction: @escaping () -> Void
    ) {
        self.state = state
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
    }
    
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack {
                Text(state.title)
                    .font(.title2)
                    .bold()
                
                Text(state.message)
                    .padding(.vertical)
                
                HStack {
                    Button(state.cancelMsg, action: cancelAction)
                        .foregroundStyle(.secondary)
                        .font(.title3)
                    
                    Spacer()
                    
                    Button(state.confirmMsg, action: confirmAction)
                        .foregroundStyle(Color.accentColor)
                        .font(.title3)
                }.padding(.horizontal)
            }
            .padding()
            .background(.white, in: RoundedRectangle(cornerRadius: 10))
            .padding()
        }
    }
}

extension TLAlert {
    public struct AlertState: Equatable {
        let title: String
        let message: String
        let cancelMsg: String
        let confirmMsg: String
        
        public init(
            title: String,
            message: String,
            cancelMsg: String,
            confirmMsg: String
        ) {
            self.title = title
            self.message = message
            self.cancelMsg = cancelMsg
            self.confirmMsg = confirmMsg
        }
    }
}

#Preview {
    TLAlert(
        state: .init(
            title: "刚开始就要放弃了吗",
            message: "少于5分钟不会被记录哦",
            cancelMsg: "离开",
            confirmMsg: "继续坚持"
        )
    ) {
        print("cancel")
    } confirmAction: {
        print("confirm")
    }
}
