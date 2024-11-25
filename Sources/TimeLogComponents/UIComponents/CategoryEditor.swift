//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/11/25.
//

import SwiftUI

public struct CategoryEditor: View {
    let bgColor: Color
    let fontColor: Color
    let activeFontColor: Color
    let deleteColor: Color
    let isValid: Bool
    @Binding var title: String
    @Binding var categoryColor: Color
    let dismiss: () -> Void
    let onSendButtonTapped: () -> Void
    let onDeleteButtonTapped: Optional<() -> Void>
    
    @FocusState private var focusedField: Bool
    
    public init(
        bgColor: Color,
        fontColor: Color,
        activeFontColor: Color,
        deleteColor: Color,
        isValid: Bool,
        title: Binding<String>,
        categoryColor: Binding<Color>,
        dismiss: @escaping () -> Void,
        onSendButtonTapped: @escaping () -> Void,
        onDeleteButtonTapped: Optional<() -> Void>
    ) {
        self.bgColor = bgColor
        self.fontColor = fontColor
        self.activeFontColor = activeFontColor
        self.deleteColor = deleteColor
        self.isValid = isValid
        self._title = title
        self._categoryColor = categoryColor
        self.dismiss = dismiss
        self.onSendButtonTapped = onSendButtonTapped
        self.onDeleteButtonTapped = onDeleteButtonTapped
    }
    
    public var body: some View {
        KeyboardEditor(
            bgColor: bgColor,
            dismiss: dismiss
        ) { size in
            VStack {
                TextField("分类名称", text: $title)
                    .focused($focusedField)
                    .font(.title3)
                
                Toolbar(
                    categoryColor: $categoryColor,
                    fontColor: fontColor,
                    activeFontColor: activeFontColor,
                    deleteColor: deleteColor,
                    isValid: isValid,
                    onSendButtonTapped: onSendButtonTapped,
                    onDeleteButtonTapped: onDeleteButtonTapped
                )
            }
            .padding()
            .onAppear {
                focusedField = true
            }
        }
    }
}

extension CategoryEditor {
    struct Toolbar: View {
        @Binding var categoryColor: Color
        let fontColor: Color
        let activeFontColor: Color
        let deleteColor: Color
        let isValid: Bool
        let onSendButtonTapped: () -> Void
        let onDeleteButtonTapped: Optional<() -> Void>
        
        var body: some View {
            HStack(spacing: 20) {
                ColorPicker("分类颜色", selection: $categoryColor)
                    .labelsHidden()
                
                Spacer()
                
                if let onDeleteButtonTapped {
                    TaskEditor_Common.DeleteButton(
                        deleteColor: deleteColor,
                        action: onDeleteButtonTapped
                    )
                }
                
                TaskEditor_Common.ConfirmButton(
                    fontColor: fontColor,
                    activeFontColor: activeFontColor,
                    action: onSendButtonTapped,
                    isValid: isValid
                )
            }
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var visible = true
        @State private var title = "xxx"
        @State private var color: Color = .gray
        
        private var isValid: Bool {
            title != "qqq"
        }
        
        var body: some View {
            ZStack {
                VStack {
                    Text("BG Content")
                    Spacer()
                }
                
                if visible {
                    CategoryEditor(
                        bgColor: .white,
                        fontColor: .black,
                        activeFontColor: .blue,
                        deleteColor: .red,
                        isValid: isValid,
                        title: $title,
                        categoryColor: $color
                    ) {
                        visible = false
                    } onSendButtonTapped: {
                        print("send")
                    } onDeleteButtonTapped: {
                        print("delete")
                    }

                } else {
                    Button("toggle") {
                        visible = true
                    }
                }
            }
        }
    }
    
    return Playground()
}
