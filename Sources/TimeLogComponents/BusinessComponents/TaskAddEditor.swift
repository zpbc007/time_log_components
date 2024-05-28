//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/5/28.
//

import SwiftUI
import IdentifiedCollections
import WrappingHStack

public struct TaskAddEditor: View {
    public struct SelectableItem: Equatable, Identifiable {
        public let id: String
        public let name: String
    }
    public typealias TagInfo = SelectableItem
    public typealias CheckListInfo = SelectableItem
    
    let bgColor: Color
    let fontColor: Color
    let activeFontColor: Color
    let tags: IdentifiedArrayOf<TagInfo>
    let checklists: IdentifiedArrayOf<CheckListInfo>
    @Binding var title: String
    @Binding var desc: String
    @Binding var selectedTags: [String]
    @Binding var selectedCheckList: String?
    let onSendButtonTapped: () -> Void
    let dismiss: () -> Void
    
    public init(
        bgColor: Color,
        fontColor: Color,
        activeFontColor: Color,
        tags: IdentifiedArrayOf<TagInfo>,
        checklists: IdentifiedArrayOf<CheckListInfo>,
        title: Binding<String>,
        desc: Binding<String>,
        selectedTags: Binding<[String]>,
        selectedCheckList: Binding<String?>,
        onSendButtonTapped: @escaping () -> Void,
        dismiss: @escaping () -> Void
    ) {
        self.bgColor = bgColor
        self.fontColor = fontColor
        self.activeFontColor = activeFontColor
        self.tags = tags
        self.checklists = checklists
        self._title = title
        self._desc = desc
        self._selectedTags = selectedTags
        self._selectedCheckList = selectedCheckList
        self.onSendButtonTapped = onSendButtonTapped
        self.dismiss = dismiss
    }
    
    private var isValid: Bool {
        !title.isEmpty
    }
    
    public var body: some View {
        KeyboardEditor(
            titlePlaceholder: "任务名称",
            descPlaceholder: "任务备注",
            bgColor: bgColor,
            title: $title,
            desc: $desc,
            dismiss: dismiss
        ) {
            VStack {
                if !selectedTags.isEmpty {
                    selectedTagView
                }
                
                // 工具栏
                HStack(spacing: 20) {
                    // tag 列表
                    tagSelectorView
                    
                    // checkList 列表
                    checkListSelectorView
                    
                    Spacer()
                    
                    confirmButtonView
                }.foregroundStyle(fontColor)
            }
        }
    }
    
    // 选中的 tag
    @ViewBuilder
    private var selectedTagView: some View {
        WrappingHStack(alignment: .leading, spacing: .dynamic(minSpacing: 10)) {
            ForEach(selectedTags, id: \.self) { tagId in
                if let tag = tags[id: tagId] {
                    Text(tag.name)
                        .padding(6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .font(.caption2)
                        .onTapGesture {
                            selectedTags.removeAll(where: { $0 == tag.id })
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private var tagSelectorView: some View {
        Menu {
            ForEach(tags) { tag in
                Button {
                    if selectedTags.contains(tag.id) {
                        selectedTags.removeAll(where: { $0 == tag.id })
                    } else {
                        selectedTags.append(tag.id)
                    }
                } label: {
                    if selectedTags.contains(tag.id) { 
                        Label(tag.name, systemImage: "checkmark")
                    } else {
                        Text(tag.name)
                    }
                }
            }
        } label: {
            Image(systemName: "tag")
                .font(.title3)
                .foregroundStyle(selectedTags.isEmpty ? fontColor : activeFontColor)
        }
    }
    
    @ViewBuilder
    private var checkListSelectorView: some View {
        Menu {
            ForEach(checklists) { checkList in
                Button {
                    if selectedCheckList == checkList.id {
                        selectedCheckList = nil
                    } else {
                        selectedCheckList = checkList.id
                    }
                } label: {
                    if selectedCheckList == checkList.id {
                        Label(checkList.name, systemImage: "checkmark")
                    } else {
                        Text(checkList.name)
                    }
                }
            }
        } label: {
            if let checkListId = selectedCheckList,
               let checkList = checklists[id: checkListId] {
                HStack {
                    Image(systemName: "tray")
                        .font(.title3)
                    
                    // 选中的 checkList
                    Text(checkList.name)
                        .font(.callout)
                }
                .foregroundStyle(activeFontColor)
            } else {
                HStack {
                    Image(systemName: "tray")
                        .font(.title3)
                }
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

#Preview {
    struct PlaygroundView: View {
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
        @State private var desc: String = ""
        @State private var selectedTags: [String] = []
        @State private var selectedCheckList: String? = nil
        @State private var visible = true
        
        var body: some View {
            ZStack {
                Color.black
                
                if visible {
                    TaskAddEditor(
                        bgColor: .white,
                        fontColor: .black,
                        activeFontColor: .blue,
                        tags: .init(uniqueElements: tags),
                        checklists: .init(uniqueElements: checklists),
                        title: $title,
                        desc: $desc,
                        selectedTags: $selectedTags,
                        selectedCheckList: $selectedCheckList
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
