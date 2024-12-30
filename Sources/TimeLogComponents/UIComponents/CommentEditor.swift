//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/24.
//

import SwiftUI

public struct CommentEditor: View {
    let placeholder: String
    let tips: [String]
    let fontColor: Color
    let activeFontColor: Color
    let bgColor: Color
    let onSendButtonTapped: () -> Void
    let dismiss: () -> Void
    
    @State private var bottomSize: CGSize = .zero
    
    public init(
        placeholder: String,
        tips: [String],
        fontColor: Color,
        activeFontColor: Color,
        bgColor: Color,
        onSendButtonTapped: @escaping () -> Void,
        dismiss: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self.tips = tips
        self.fontColor = fontColor
        self.activeFontColor = activeFontColor
        self.bgColor = bgColor
        self.onSendButtonTapped = onSendButtonTapped
        self.dismiss = dismiss
    }
    
    public var body: some View {
        KeyboardEditor(bgColor: bgColor, dismiss: dismiss) { size in
            VStack(spacing: 0) {
                RichTextEditor(
                    placeholder: placeholder,
                    maxHeight: size.height - bottomSize.height
                ).background(
                    .ultraThickMaterial,
                    in: RoundedRectangle(cornerRadius: 10)
                )
               
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(tips, id: \.self) { tip in
                            Text(tip)
                        }
                    }.font(.footnote)
                    .fontWeight(.light)
                    
                    Spacer()
                }.padding(.top, 5)
                
                HStack {
                    Spacer()
                    
                    TaskEditor_Common.ConfirmButton(
                        fontColor: fontColor,
                        activeFontColor: activeFontColor,
                        action: onSendButtonTapped,
                        isValid: true
                    )
                }
                .padding(.top)
                .contentSize()
                .onPreferenceChange(SizePreferenceKey.self, perform: { value in
                    bottomSize = value
                })
            }.padding()
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var showEditor = true
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
                        placeholder: "今日的目标是：",
                        tips: [
                            "- 今天最重要的事情是什么？",
                            "- 准备做什么让自己更健康？",
                            "- 准备做什么让自己开心？",
                            "- 今天有要学习或者探索的新事物吗？"
                        ],
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
