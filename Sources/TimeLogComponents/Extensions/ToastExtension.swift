//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/2.
//

import SwiftUI
import AlertToast

public struct ToastState: Equatable {
    let message: String
    let type: AlertToast.AlertType
    
    public init(message: String, type: AlertToast.AlertType) {
        self.message = message
        self.type = type
    }
}

extension View {
    public func toast(_ isPresenting: Binding<Bool>, state: ToastState) -> some View {
        self.toast(isPresenting: isPresenting) {
            AlertToast(
                type: state.type,
                title: state.message
            )
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var showToast = false
        private let toastState: ToastState = .init(message: "测试内容", type: .error(.red))
        
        var body: some View {
            ZStack {
                Color.gray
                
                Button("toggle") {
                    showToast.toggle()
                }
            }
            .ignoresSafeArea()
            .toast($showToast, state: toastState)
        }
    }
    
    return Playground()
}
