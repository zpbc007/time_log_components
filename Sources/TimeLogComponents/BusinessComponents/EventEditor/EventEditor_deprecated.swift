//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/7/11.
//

import SwiftUI
import IdentifiedCollections

public struct TaskEditor: View {
    public typealias TagInfo = TimeLogSelectable
    public typealias CheckListInfo = TimeLogSelectable
    
    let fontColor: Color
    let activeFontColor: Color
    let tags: IdentifiedArrayOf<TagInfo>
    let checklists: IdentifiedArrayOf<CheckListInfo>
    let onSendButtonTapped: () -> Void
    @Binding var title: String
    @Binding var selectedTags: [String]
    @Binding var selectedCheckList: String?
    
    @FocusState private var titleFocused: Bool
    
    public init(
        fontColor: Color,
        activeFontColor: Color,
        tags: IdentifiedArrayOf<TagInfo>,
        checklists: IdentifiedArrayOf<CheckListInfo>,
        title: Binding<String>,
        selectedTags: Binding<[String]>,
        selectedCheckList: Binding<String?>,
        onSendButtonTapped: @escaping () -> Void
    ) {
        self.fontColor = fontColor
        self.activeFontColor = activeFontColor
        self.tags = tags
        self.checklists = checklists
        self._title = title
        self._selectedTags = selectedTags
        self._selectedCheckList = selectedCheckList
        self.onSendButtonTapped = onSendButtonTapped
    }
    
    private var isValid: Bool {
        !title.isEmpty
    }
    
    public var body: some View {
        VStack {
            TextField("任务名称", text: $title)
                .font(.title)
                .focused($titleFocused)
            
            RichTextEditor(placeholder: "备注")
            
            TaskEditor_Common.TaskToolbar(
                fontColor: fontColor,
                activeFontColor: activeFontColor,
                deleteColor: .red,
                checklists: checklists,
                isValid: isValid,
                selectedCheckList: $selectedCheckList,
                onSendButtonTapped: onSendButtonTapped
            )
        }
        .padding()
        .task {
            titleFocused = true
        }
    }
}

#Preview {
    struct Playground: View {
        let tags: [TaskEditor.TagInfo] = [
            .init(id: UUID().uuidString, name: "时间投资/01消费"),
            .init(id: UUID().uuidString, name: "时间投资/02投资"),
            .init(id: UUID().uuidString, name: "时间投资/03浪费"),
            .init(id: UUID().uuidString, name: "时间投资/04消耗")
        ]
        let checklists: [EventEditor.CheckListInfo] = [
            .init(id: UUID().uuidString, name: "健身"),
            .init(id: UUID().uuidString, name: "日常"),
            .init(id: UUID().uuidString, name: "工作"),
            .init(id: UUID().uuidString, name: "玩乐")
        ]
        
        @State private var title: String = ""
        @State private var selectedTags: [String] = []
        @State private var selectedCheckList: String? = nil
        @StateObject private var editorVM = RichTextEditor.ViewModel("")
        
        var body: some View {
            NavigationStack {
                TaskEditor(
                    fontColor: .black,
                    activeFontColor: .blue,
                    tags: .init(uniqueElements: tags),
                    checklists: .init(uniqueElements: checklists),
                    title: $title,
                    selectedTags: $selectedTags,
                    selectedCheckList: $selectedCheckList
                ) {
                    print("send")
                }
                .environmentObject(editorVM)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("保存") {
                            
                        }
                    }
                }
                .dismissBtn()
            }
        }
    }
    
    return Playground()
}
