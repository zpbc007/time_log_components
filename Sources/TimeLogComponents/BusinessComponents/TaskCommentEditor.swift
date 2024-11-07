//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/9/26.
//

import SwiftUI

public struct TaskCommentEditor: View {
    let fontColor: Color
    let activeFontColor: Color
    let bgColor: Color
    let onSendButtonTapped: () -> Void
    let dismiss: () -> Void
    
    @State private var bottomSize: CGSize = .zero
    
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
        KeyboardEditor(
            bgColor: bgColor,
            dismiss: dismiss
        ) { size in
            VStack {
                RichTextEditor(placeholder: "备注", maxHeight: size.height - bottomSize.height)
                    .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 10))
                
                HStack {
                    Spacer()
                    
                    TaskEditor_Common.ConfirmButton(
                        fontColor: fontColor,
                        activeFontColor: activeFontColor,
                        action: onSendButtonTapped,
                        isValid: true
                    )
                }
                .contentSize()
                .onPreferenceChange(SizePreferenceKey.self, perform: { value in
                    bottomSize = value
                })
                .padding(.top)
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
                    showEditor.toggle()
                }
                
                if showEditor {
                    TaskCommentEditor(
                        fontColor: .primary, 
                        activeFontColor: .blue,
                        bgColor: .white
                    ) {
                        print("confirm")
                    } dismiss: {
                        showEditor = false
                    }.environmentObject(editorVM)
                }
            }
        }
    }
    
    return Playground()
}
