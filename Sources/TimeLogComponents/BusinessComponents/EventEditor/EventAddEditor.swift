//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/5/28.
//

import SwiftUI
import IdentifiedCollections
import WrappingHStack

public struct EventAddEditor {
    public typealias CheckListInfo = TimeLogSelectable
}

extension EventAddEditor {
    public struct MainView<Content: View>: View {
        let bgColor: Color
        let fontColor: Color
        let activeFontColor: Color
        let checklists: IdentifiedArrayOf<CheckListInfo>
        @Binding var title: String
        @Binding var selectedCheckList: String?
        let content: () -> Content
        let onSendButtonTapped: () -> Void
        let dismiss: () -> Void
        
        @FocusState private var focusedField: Bool
        
        public init(
            bgColor: Color,
            fontColor: Color,
            activeFontColor: Color,
            checklists: IdentifiedArrayOf<CheckListInfo>,
            title: Binding<String>,
            selectedCheckList: Binding<String?>,
            @ViewBuilder
            content: @escaping () -> Content,
            onSendButtonTapped: @escaping () -> Void,
            dismiss: @escaping () -> Void
        ) {
            self.bgColor = bgColor
            self.fontColor = fontColor
            self.activeFontColor = activeFontColor
            self.checklists = checklists
            self._title = title
            self._selectedCheckList = selectedCheckList
            self.content = content
            self.onSendButtonTapped = onSendButtonTapped
            self.dismiss = dismiss
        }
        
        private var isValid: Bool {
            !title.isEmpty
        }
        
        public var body: some View {
            KeyboardEditor(
                bgColor: bgColor,
                dismiss: dismiss
            ) { size in
                VStack {
                    TextField("任务名称", text: $title)
                        .focused($focusedField)
                        .font(.title3)
                    
                    content()
     
                    TaskEditor_Common.TaskToolbar(
                        fontColor: fontColor,
                        activeFontColor: activeFontColor,
                        checklists: checklists,
                        isValid: isValid,
                        selectedCheckList: $selectedCheckList,
                        onSendButtonTapped: onSendButtonTapped
                    )
                }
                .padding()
                .onAppear {
                    focusedField = true
                }
            }
        }
        
        @ViewBuilder
        private var confirmButtonView: some View {
            Button(action: onSendButtonTapped) {
                Image(systemName: "arrow.up.circle")
                    .font(.title)
                    .foregroundStyle(isValid ? activeFontColor : fontColor)
            }.disabled(!isValid)
        }
    }
}

#Preview {
    struct PlaygroundView: View {
        let checklists: [EventAddEditor.CheckListInfo] = [
            .init(id: UUID().uuidString, name: "健身"),
            .init(id: UUID().uuidString, name: "日常"),
            .init(id: UUID().uuidString, name: "工作"),
            .init(id: UUID().uuidString, name: "玩乐")
        ]
        
        @State private var title: String = ""
        @State private var selectedCheckList: String? = nil
        @State private var visible = true
        
        var body: some View {
            ZStack {
                Color.gray
                
                if visible {
                    EventAddEditor.MainView(
                        bgColor: .white,
                        fontColor: .black,
                        activeFontColor: .blue,
                        checklists: .init(uniqueElements: checklists),
                        title: $title,
                        selectedCheckList: $selectedCheckList,
                        content: {
                            Text("Tag Picker")
                        }
                    ) {
                        visible = false
                    } dismiss: {
                        visible = false
                    }
                } else {
                    Button("click me") {
                        visible = true
                    }
                }
            }
        }
    }
    
    return PlaygroundView()
}
