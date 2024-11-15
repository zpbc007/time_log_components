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
    
    struct CategorySelector: View {
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
    
    struct ConfirmButton: View {
        let fontColor: Color
        let activeFontColor: Color
        let action: () -> Void
        let isValid: Bool
        
        init(
            fontColor: Color,
            activeFontColor: Color,
            action: @escaping () -> Void,
            isValid: Bool
        ) {
            self.fontColor = fontColor
            self.activeFontColor = activeFontColor
            self.action = action
            self.isValid = isValid
        }
        
        var body: some View {
            Button(action: action) {
                Image(systemName: "arrow.up.circle")
                    .font(.title)
                    .foregroundStyle(isValid ? activeFontColor : fontColor)
            }
        }
    }
    
    struct TaskToolbar: View {
        let fontColor: Color
        let activeFontColor: Color
        let checklists: IdentifiedArrayOf<TimeLogSelectable>
        let isValid: Bool
        @Binding var selectedCheckList: String?
        let onSendButtonTapped: () -> Void
        
        var body: some View {
            // 工具栏
            HStack(spacing: 20) {
                TaskEditor_Common.CategorySelector(
                    activeFontColor: activeFontColor,
                    checklists: checklists,
                    selected: $selectedCheckList
                )
                
                Spacer()
                
                TaskEditor_Common.ConfirmButton(
                    fontColor: fontColor,
                    activeFontColor: activeFontColor,
                    action: onSendButtonTapped,
                    isValid: isValid
                )
            }.foregroundStyle(fontColor)
        }
    }
}

#Preview {
    struct Playground: View {
        let checklists: IdentifiedArrayOf<TimeLogSelectable> = .init(uniqueElements: [
            .init(id: UUID().uuidString, name: "健身"),
            .init(id: UUID().uuidString, name: "日常"),
            .init(id: UUID().uuidString, name: "工作"),
            .init(id: UUID().uuidString, name: "玩乐")
        ])
        @State private var selectedTags: [String] = []
        @State private var selectedCheckList: String? = nil
        
        var body: some View {
            TaskEditor_Common.TaskToolbar(
                fontColor: .primary,
                activeFontColor: .blue,
                checklists: checklists,
                isValid: true,
                selectedCheckList: $selectedCheckList
            ) {
                print("confirm")
            }.padding()
        }
    }
    
    return Playground()
}
