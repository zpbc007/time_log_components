//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/24.
//

import SwiftUI

public struct CommentEditor: View {
    let fontColor: Color
    let activeFontColor: Color
    let bgColor: Color
    let onSendButtonTapped: () -> Void
    let dismiss: () -> Void
    
    public init(
        fontColor: Color,
        activeFontColor: Color,
        bgColor: Color,
        onSendButtonTapped: @escaping () -> Void,
        dismiss: @escaping () -> Void
    ) {
        self.fontColor = fontColor
        self.activeFontColor = activeFontColor
        self.bgColor = bgColor
        self.onSendButtonTapped = onSendButtonTapped
        self.dismiss = dismiss
    }
    
    public var body: some View {
        KeyboardEditor(bgColor: bgColor, dismiss: dismiss) {
            VStack {
                RichTextEditor()
                    .frame(maxHeight: 200)
                
                HStack {
                    Spacer()
                    
                    TaskEditor_Common.ConfirmButton(
                        fontColor: fontColor,
                        activeFontColor: activeFontColor,
                        action: onSendButtonTapped,
                        isValid: true
                    )
                }.padding(.top)
            }.padding()
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var showEditor = false
        @StateObject var editorVM: RichTextEditor.ViewModel = .init()
        
        var body: some View {
            ZStack {
                Button("click") {
                    withAnimation {
                        showEditor.toggle()
                    }
                }
                
                if showEditor {
                    CommentEditor(
                        fontColor: .primary,
                        activeFontColor: .blue,
                        bgColor: .white
                    ) {
                        print("onSendButtonTapped")
                    } dismiss: {
                        showEditor = false
                    }
                    .environmentObject(editorVM)
                }
            }
            
        }
    }
    
    return Playground()
}
