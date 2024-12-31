//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/5/28.
//

import SwiftUI
import IdentifiedCollections
import WrappingHStack

public struct EventEditor {
    public typealias CheckListInfo = TimeLogSelectable
}

extension EventEditor {
    public struct MainView<Content: View>: View {
        let bgColor: Color
        let fontColor: Color
        let activeFontColor: Color
        let deleteColor: Color
        let imageName: String?
        let checklists: IdentifiedArrayOf<CheckListInfo>
        @Binding var title: String
        @Binding var selectedCheckList: String?
        let content: () -> Content
        let onSendButtonTapped: () -> Void
        let dismiss: () -> Void
        let onDeleteButtonTapped: Optional<() -> Void>
        
        @FocusState private var focusedField: Bool
        
        // Add
        public init(
            bgColor: Color,
            fontColor: Color,
            activeFontColor: Color,
            deleteColor: Color,
            imageName: String? = nil,
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
            self.deleteColor = deleteColor
            self.imageName = imageName
            self.checklists = checklists
            self._title = title
            self._selectedCheckList = selectedCheckList
            self.content = content
            self.onSendButtonTapped = onSendButtonTapped
            self.dismiss = dismiss
            self.onDeleteButtonTapped = nil
        }
        
        // Edit
        public init(
            bgColor: Color,
            fontColor: Color,
            activeFontColor: Color,
            deleteColor: Color,
            imageName: String? = nil,
            checklists: IdentifiedArrayOf<CheckListInfo>,
            title: Binding<String>,
            selectedCheckList: Binding<String?>,
            @ViewBuilder
            content: @escaping () -> Content,
            onSendButtonTapped: @escaping () -> Void,
            dismiss: @escaping () -> Void,
            onDeleteButtonTapped: @escaping () -> Void
        ) {
            self.bgColor = bgColor
            self.fontColor = fontColor
            self.activeFontColor = activeFontColor
            self.deleteColor = deleteColor
            self.imageName = imageName
            self.checklists = checklists
            self._title = title
            self._selectedCheckList = selectedCheckList
            self.content = content
            self.onSendButtonTapped = onSendButtonTapped
            self.dismiss = dismiss
            self.onDeleteButtonTapped = onDeleteButtonTapped
        }
        
        private var isValid: Bool {
            !title.isEmpty
        }
        
        public var body: some View {
            KeyboardEditor(
                bgColor: bgColor,
                radiusConfig: .init(leading: 10, trailing: 0),
                dismiss: dismiss
            ) { size in
                VStack {
                    TextField("事件名称", text: $title)
                        .focused($focusedField)
                        .font(.title3)
                    
                    content()
     
                    if let onDeleteButtonTapped {
                        TaskEditor_Common.TaskToolbar(
                            fontColor: fontColor,
                            activeFontColor: activeFontColor,
                            deleteColor: deleteColor,
                            checklists: checklists,
                            isValid: isValid,
                            selectedCheckList: $selectedCheckList,
                            onSendButtonTapped: onSendButtonTapped,
                            onDeleteButtonTapped: onDeleteButtonTapped
                        )
                    } else {
                        TaskEditor_Common.TaskToolbar(
                            fontColor: fontColor,
                            activeFontColor: activeFontColor,
                            deleteColor: deleteColor,
                            checklists: checklists,
                            isValid: isValid,
                            selectedCheckList: $selectedCheckList,
                            onSendButtonTapped: onSendButtonTapped
                        )
                    }
                }
                .padding()
                .overlay(
                    alignment: .topTrailing,
                    content: {
                        if let imageName {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .offset(y: -120)
                                .transition(.opacity)
                                .animation(.easeInOut, value: imageName)
                        }
                    }
                )
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

#Preview("Add") {
    struct PlaygroundView: View {
        let checklists: [EventEditor.CheckListInfo] = [
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
                    EventEditor.MainView(
                        bgColor: .white,
                        fontColor: .black,
                        activeFontColor: .blue,
                        deleteColor: .red,
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

#Preview("Edit") {
    struct PlaygroundView: View {
        let checklists: [EventEditor.CheckListInfo] = [
            .init(id: UUID().uuidString, name: "健身"),
            .init(id: UUID().uuidString, name: "日常"),
            .init(id: UUID().uuidString, name: "工作"),
            .init(id: UUID().uuidString, name: "玩乐")
        ]
        
        @State private var title: String = "123"
        @State private var selectedCheckList: String? = nil
        @State private var visible = true
        
        var body: some View {
            ZStack {
                Color.gray
                
                if visible {
                    EventEditor.MainView(
                        bgColor: .white,
                        fontColor: .black,
                        activeFontColor: .blue,
                        deleteColor: .red,
                        imageName: "",
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
                    } onDeleteButtonTapped: {
                        print("delete")
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
