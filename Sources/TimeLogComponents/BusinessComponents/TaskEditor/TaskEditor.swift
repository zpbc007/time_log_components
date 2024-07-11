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
    @Binding var title: String
    @Binding var commentDeltaJson: String
    @Binding var selectedTags: [String]
    @Binding var selectedCheckList: String?
    @State private var fetchContentId = UUID().uuidString
    @FocusState private var titleFocused: Bool
    
    public init(
        fontColor: Color,
        activeFontColor: Color,
        tags: IdentifiedArrayOf<TagInfo>,
        checklists: IdentifiedArrayOf<CheckListInfo>,
        title: Binding<String>,
        commentDeltaJson: Binding<String>,
        selectedTags: Binding<[String]>,
        selectedCheckList: Binding<String?>
    ) {
        self.fontColor = fontColor
        self.activeFontColor = activeFontColor
        self.tags = tags
        self.checklists = checklists
        self._title = title
        self._commentDeltaJson = commentDeltaJson
        self._selectedTags = selectedTags
        self._selectedCheckList = selectedCheckList
    }
    
    private var isValid: Bool {
        !title.isEmpty
    }
    
    public var body: some View {
        VStack {
            TextField("任务名称", text: $title)
                .font(.title)
                .padding()
                .focused($titleFocused)
            
            RichTextEditor(
                content: $commentDeltaJson,
                fetchContentId: $fetchContentId
            )
            
            // tags checklist selector
            VStack {
                if !selectedTags.isEmpty {
                    TaskEditor_Common.SelectedTags(
                        tags: tags,
                        selected: $selectedTags
                    )
                }
                
                // 工具栏
                HStack(spacing: 20) {
                    // tag 列表
                    TaskEditor_Common.TagSelector(
                        fontColor: fontColor,
                        activeFontColor: activeFontColor,
                        tags: tags,
                        selected: $selectedTags
                    )
                    
                    // checkList 列表
                    TaskEditor_Common.CheckListSelector(
                        activeFontColor: activeFontColor,
                        checklists: checklists,
                        selected: $selectedCheckList
                    )
                    
                    Spacer()
                }.foregroundStyle(fontColor)
            }
        }.task {
            titleFocused = true
        }
    }
}

#Preview {
    struct Playground: View {
        let tags: [TaskAddEditor.TagInfo] = [
            .init(id: UUID().uuidString, name: "时间投资/01消费"),
            .init(id: UUID().uuidString, name: "时间投资/02投资"),
            .init(id: UUID().uuidString, name: "时间投资/03浪费"),
            .init(id: UUID().uuidString, name: "时间投资/04消耗")
        ]
        let checklists: [TaskAddEditor.CheckListInfo] = [
            .init(id: UUID().uuidString, name: "健身"),
            .init(id: UUID().uuidString, name: "日常"),
            .init(id: UUID().uuidString, name: "工作"),
            .init(id: UUID().uuidString, name: "玩乐")
        ]
        
        @State private var title: String = ""
        @State private var commentDeltaJson: String = ""
        @State private var selectedTags: [String] = []
        @State private var selectedCheckList: String? = nil
        
        var body: some View {
            NavigationStack {
                TaskEditor(
                    fontColor: .black,
                    activeFontColor: .blue,
                    tags: .init(uniqueElements: tags),
                    checklists: .init(uniqueElements: checklists),
                    title: $title,
                    commentDeltaJson: $commentDeltaJson,
                    selectedTags: $selectedTags,
                    selectedCheckList: $selectedCheckList
                )
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
