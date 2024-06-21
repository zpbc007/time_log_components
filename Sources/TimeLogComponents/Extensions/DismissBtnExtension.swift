//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/19.
//

import SwiftUI

public struct DismissModifier: ViewModifier {
    public enum CancelText: String {
        case cancel = "取消"
        case back = "返回"
    }
    
    @Environment(\.dismiss) private var dismiss
    let cancelText: CancelText
    let showDismissBtn: Bool
    
    public init() {
        self.showDismissBtn = true
        self.cancelText = .back
    }
    
    public init(showDismissBtn: Bool, cancelText: CancelText) {
        self.showDismissBtn = showDismissBtn
        self.cancelText = cancelText
    }
    
    public func body(content: Content) -> some View {
        if showDismissBtn {
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("返回")
                                Spacer()
                            }
                        }
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    public func dismissBtn(show: Bool = true, cancelText: DismissModifier.CancelText = .back) -> some View {
        modifier(DismissModifier(showDismissBtn: show, cancelText: cancelText))
    }
}

#Preview("show") {
    NavigationStack {
        NavigationLink {
            Text("xxx")
                .navigationBarBackButtonHidden()
                .dismissBtn()
        } label: {
            Text("tap me")
        }
    }
}

#Preview("hide") {
    NavigationStack {
        NavigationLink {
            Text("xxx")
                .dismissBtn(show: false)
        } label: {
            Text("tap me")
        }
    }
}
