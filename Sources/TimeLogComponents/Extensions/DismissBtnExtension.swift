//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/19.
//

import SwiftUI

struct DismissModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    let showDismissBtn: Bool
    
    init() {
        self.showDismissBtn = true
    }
    
    init(showDismissBtn: Bool) {
        self.showDismissBtn = showDismissBtn
    }
    
    func body(content: Content) -> some View {
        if showDismissBtn {
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Label("返回", systemImage: "chevron.left")
                                .labelStyle(.titleAndIcon)
                                .bold()
                        }
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    public func dismissBtn(show: Bool = true) -> some View {
        modifier(DismissModifier(showDismissBtn: show))
    }
}

#Preview("show") {
    NavigationStack {
        NavigationLink {
            NavigationStack {
                Text("xxx")
                    .dismissBtn()
            }
            
        } label: {
            Text("tap me")
        }
    }
}

#Preview("hide") {
    NavigationStack {
        NavigationLink {
            NavigationStack {
                Text("xxx")
                    .dismissBtn(show: false)
            }
            
        } label: {
            Text("tap me")
        }
    }
}
