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
    var cancelAction: Optional<() -> Void> = nil
    
    public init() {
        self.showDismissBtn = true
        self.cancelText = .back
    }
    
    public init(
        showDismissBtn: Bool,
        cancelText: CancelText
    ) {
        self.showDismissBtn = showDismissBtn
        self.cancelText = cancelText
    }
    
    public init(
        showDismissBtn: Bool,
        cancelText: CancelText,
        cancelAction: @escaping () -> Void
    ) {
        self.showDismissBtn = showDismissBtn
        self.cancelText = cancelText
        self.cancelAction = cancelAction
    }
    
    public func body(content: Content) -> some View {
        if showDismissBtn {
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            if let cancelAction {
                                cancelAction()
                            } else {
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text(self.cancelText.rawValue)
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
    public func dismissBtn(
        show: Bool = true,
        cancelText: DismissModifier.CancelText = .back,
        cancelAction: Optional<() -> Void> = nil
    ) -> some View {
        if let cancelAction {
            modifier(DismissModifier(
                showDismissBtn: show,
                cancelText: cancelText,
                cancelAction: cancelAction
            ))
        } else {
            modifier(DismissModifier(
                showDismissBtn: show,
                cancelText: cancelText
            ))
        }
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
