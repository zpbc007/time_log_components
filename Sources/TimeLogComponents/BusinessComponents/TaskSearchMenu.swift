//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/19.
//

import SwiftUI
import IdentifiedCollections

public struct TaskSearchMenu: View {
    let menus: IdentifiedArrayOf<MenuSidebar.TreeMenuValue>
    @Binding var selection: MenuSidebar.SidebarMenuValue?
    
    public init(
        menus: IdentifiedArrayOf<MenuSidebar.TreeMenuValue>,
        selection: Binding<MenuSidebar.SidebarMenuValue?>
    ) {
        self.menus = menus
        self._selection = selection
    }
    
    public var body: some View {
        List {
            OutlineGroup(menus, children: \.children) { item in
                if item.value.mode == .readonly {
                    cellContent(item)
                } else {
                    Group {
                        if item.id == selection?.id {
                            cellContent(item)
                                .foregroundStyle(.selection)
                        } else {
                            cellContent(item)
                                .foregroundStyle(.primary)
                        }
                    }
                    .onTapGesture {
                        selection = item.value
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func cellContent(_ item: MenuSidebar.TreeMenuValue) -> some View {
        MenuSidebar.MenuCellContent(item.value)
            .contentShape(Rectangle())
            
    }
}

extension TaskSearchMenu {
    struct Sheet:View {
        let menus: IdentifiedArrayOf<MenuSidebar.TreeMenuValue>
        @Binding var selection: MenuSidebar.SidebarMenuValue?
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            TaskSearchMenu(menus: menus, selection: $selection)
                .onChange(of: selection) { oldValue, newValue in
                    dismiss()
                }
                .navigationTitle("任务列表")
                .dismissBtn()
        }
    }
}

#Preview {
    struct Playground: View {
        let menus: IdentifiedArrayOf<MenuSidebar.TreeMenuValue> = .init(uniqueElements: [
            .init(value: .init(
                id: UUID().uuidString,
                text: "menu1",
                mode: .selectable
            )),
            .init(value: .init(
                id: UUID().uuidString,
                text: "menu2",
                mode: .selectable
            )),
            .init(value: .init(
                id: UUID().uuidString,
                text: "tags",
                mode: .readonly
            ), children: .init(uniqueElements: [
                .init(value: .init(
                    id: UUID().uuidString,
                    text: "menu3-1",
                    mode: .selectable
                )),
                .init(value: .init(
                    id: UUID().uuidString,
                    text: "menu3-2",
                    mode: .selectable
                )),
            ]))
        ])
        @State private var selection: MenuSidebar.SidebarMenuValue? = nil
        @State private var showMenu = true
        
        var body: some View {
            NavigationStack {
                Button("show menu current is: \(selection?.text ?? "null")") {
                    showMenu.toggle()
                }
                .sheet(isPresented: $showMenu, content: {
                    NavigationStack {
                        TaskSearchMenu.Sheet(menus: menus, selection: $selection)
                    }
                })
            }
        }
    }

    return Playground()
}
