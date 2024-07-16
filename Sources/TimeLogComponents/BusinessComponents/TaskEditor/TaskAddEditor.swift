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
    enum Field: Hashable {
        case title
        case desc
    }
    
    public typealias TagInfo = TimeLogSelectable
    public typealias CheckListInfo = TimeLogSelectable
    
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
    
    @FocusState private var focusedField: Field?
    
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
            bgColor: bgColor,
            dismiss: dismiss
        ) {
            VStack {
                TextField("任务名称", text: $title)
                    .focused($focusedField, equals: .title)
                    .font(.title3)
                
                TextField("任务备注", text: $desc, axis: .vertical)
                    .lineLimit(2...10)
                    .focused($focusedField, equals: .desc)
                    .font(.callout)
                
                TaskEditor_Common.TaskToolbar(
                    fontColor: fontColor,
                    activeFontColor: activeFontColor,
                    tags: tags,
                    checklists: checklists,
                    isValid: isValid,
                    selectedTags: $selectedTags,
                    selectedCheckList: $selectedCheckList,
                    onSendButtonTapped: onSendButtonTapped
                )
            }
            .padding()
            .onAppear {
                focusedField = .title
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
                Color.gray
                
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
