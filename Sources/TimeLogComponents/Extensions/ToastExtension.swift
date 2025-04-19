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
            self.getToastView(state)
        }
    }
    
    public func toast(_ state: Binding<ToastState?>) -> some View {
        self.toast(
            isPresenting: self.getIsPresenting(state)
        ) {
            self.getToastView(state.wrappedValue)
        }
    }
    
    public func toast(
        _ state: Binding<ToastState?>,
        onTap: @escaping () -> Void
    ) -> some View {
        self.toast(
            isPresenting: self.getIsPresenting(state),
            duration: 0,
            tapToDismiss: false,
            alert: {
                self.getToastView(state.wrappedValue)
            },
            onTap: onTap
        )
    }
    
    private func getIsPresenting(_ state: Binding<ToastState?>) -> Binding<Bool> {
        .init(
            get: {
                state.wrappedValue != nil
            },
            set: { visible in
                if !visible {
                    state.wrappedValue = nil
                }
            }
        )
    }
    
    private func getToastView(_ state: ToastState?) -> AlertToast {
        AlertToast(
            type: state?.type ?? .regular,
            title: state?.message
        )
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

#Preview("Binding State") {
    struct Playground: View {
        @State private var toastState: ToastState? = nil
        
        var body: some View {
            ZStack {
                Color.gray
                
                Button("toggle") {
                    toastState = .init(message: "测试内容 \(Date.now)", type: .error(.red))
                }
            }
            .ignoresSafeArea()
            .toast($toastState)
        }
    }
    
    return Playground()
}

#Preview("only tap to dismiss") {
    struct Playground: View {
        @State private var toastState: ToastState? = nil
        
        var body: some View {
            ZStack {
                Color.gray
                
                Button("toggle") {
                    toastState = .init(message: "测试内容 \(Date.now)", type: .error(.red))
                }
            }
            .ignoresSafeArea()
            .toast($toastState) {
                toastState = nil
            }
        }
    }
    
    return Playground()
}
