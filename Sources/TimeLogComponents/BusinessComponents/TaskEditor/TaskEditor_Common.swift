//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/12.
//

import SwiftUI
import IdentifiedCollections
import WrappingHStack

struct TaskEditor_Common {
    struct TagSelector: View {
        let fontColor: Color
        let activeFontColor: Color
        let tags: IdentifiedArrayOf<TimeLogSelectable>
        @Binding var selected: [String]
        
        var body: some View {
            Menu {
                ForEach(tags) { tag in
                    Button {
                        if selected.contains(tag.id) {
                            selected.removeAll(where: { $0 == tag.id })
                        } else {
                            selected.append(tag.id)
                        }
                    } label: {
                        if selected.contains(tag.id) {
                            Label(tag.name, systemImage: "checkmark")
                        } else {
                            Text(tag.name)
                        }
                    }
                }
            } label: {
                Image(systemName: "tag")
                    .font(.title3)
                    .foregroundStyle(selected.isEmpty ? fontColor : activeFontColor)
            }
        }
    }
    
    struct SelectedTags: View {
        let tags: IdentifiedArrayOf<TimeLogSelectable>
        @Binding var selected: [String]
        
        var body: some View {
            WrappingHStack(alignment: .leading, spacing: .dynamic(minSpacing: 10)) {
                ForEach(selected, id: \.self) { tagId in
                    if let tag = tags[id: tagId] {
                        Text(tag.name)
                            .padding(6)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            .font(.caption2)
                            .onTapGesture {
                                selected.removeAll(where: { $0 == tag.id })
                            }
                    }
                }
            }
        }
    }
    
    struct CheckListSelector: View {
        let activeFontColor: Color
        let checklists: IdentifiedArrayOf<TimeLogSelectable>
        @Binding var selected: String?
        
        var body: some View {
            Menu {
                ForEach(checklists) { checkList in
                    Button {
                        if selected == checkList.id {
                            selected = nil
                        } else {
                            selected = checkList.id
                        }
                    } label: {
                        if selected == checkList.id {
                            Label(checkList.name, systemImage: "checkmark")
                        } else {
                            Text(checkList.name)
                        }
                    }
                }
            } label: {
                if let checkListId = selected,
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
    }
}

#Preview {
    struct Playground: View {
        let tags: IdentifiedArrayOf<TimeLogSelectable> = .init(uniqueElements: [
            .init(id: UUID().uuidString, name: "时间投资/01消费"),
            .init(id: UUID().uuidString, name: "时间投资/02投资"),
            .init(id: UUID().uuidString, name: "时间投资/03浪费"),
            .init(id: UUID().uuidString, name: "时间投资/04消耗")
        ])
        let checklists: IdentifiedArrayOf<TimeLogSelectable> = .init(uniqueElements: [
            .init(id: UUID().uuidString, name: "健身"),
            .init(id: UUID().uuidString, name: "日常"),
            .init(id: UUID().uuidString, name: "工作"),
            .init(id: UUID().uuidString, name: "玩乐")
        ])
        @State private var selectedTags: [String] = []
        @State private var selectedCheckList: String? = nil
        
        var body: some View {
            VStack {
                HStack {
                    TaskEditor_Common.TagSelector(
                        fontColor: .primary,
                        activeFontColor: .blue,
                        tags: tags,
                        selected: $selectedTags
                    )
                    TaskEditor_Common.SelectedTags(tags: tags, selected: $selectedTags)
                }
                
                HStack {
                    TaskEditor_Common.CheckListSelector(
                        activeFontColor: .blue,
                        checklists: checklists,
                        selected: $selectedCheckList
                    )
                }
            }.padding()
            
        }
    }
    
    return Playground()
}
