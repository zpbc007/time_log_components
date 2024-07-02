//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/20.
//

import SwiftUI
import IdentifiedCollections

public struct TaskSelector: View {
    let menus: IdentifiedArrayOf<MenuSidebar.TreeMenuValue>
    let tasks: IdentifiedArrayOf<TreeTaskValue>
    
    @Binding var selectedTask: TaskItem?
    @Binding var selectedMenu: MenuSidebar.SidebarMenuValue?
    @Binding var searchText: String
    
    @State private var showTaskSearchMenu = false
    
    private var filteredTasks: IdentifiedArrayOf<TreeTaskValue> {
        if (searchText.isEmpty) {
            return tasks
        }
        
        return CommonTreeNode.filter(tree: tasks) { node in
            node.name.contains(searchText)
        }
    }
    
    public init(
        menus: IdentifiedArrayOf<MenuSidebar.TreeMenuValue>,
        tasks: IdentifiedArrayOf<TreeTaskValue>,
        selectedTask: Binding<TaskItem?>,
        selectedMenu: Binding<MenuSidebar.SidebarMenuValue?>,
        searchText: Binding<String>
    ) {
        self.menus = menus
        self.tasks = tasks
        self._selectedTask = selectedTask
        self._selectedMenu = selectedMenu
        self._searchText = searchText
    }
    
    public var body: some View {
        Form {
            TextField("搜索", text: $searchText)
            
            Section(header: tasksHeader) {
                if filteredTasks.isEmpty {
                    HStack {
                        Spacer()
                        Text("无任务")
                        Spacer()
                    }
                    
                } else {
                    List {
                        OutlineGroup(filteredTasks, children: \.children) { item in
                            Group {
                                HStack {
                                    if item.id == selectedTask?.id {
                                        Text(item.value.name)
                                            .foregroundStyle(.selection)
                                    } else {
                                        Text(item.value.name)
                                            .foregroundStyle(.primary)
                                    }
                                    
                                    Spacer()
                                }
                                
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTask = item.value
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showTaskSearchMenu) {
            NavigationStack {
                TaskSearchMenu.Sheet(menus: menus, selection: $selectedMenu)
            }
        }
        .navigationTitle("选择任务")
        .onChange(of: selectedMenu) { oldValue, newValue in
            searchText = ""
        }
    }
    
    @ViewBuilder
    private var tasksHeader: some View {
        Button {
            showTaskSearchMenu = true
        } label: {
            HStack {
                if let selectedMenu {
                    MenuSidebar.MenuCellContent(selectedMenu, addSpacer: false)
                } else {
                    Text("任务列表")
                }
                
                Image(systemName: "chevron.right")
                
                Spacer()
            }
            .font(.caption)
        }
    }
}

extension TaskSelector {
    public struct TaskItem: Equatable, Identifiable {
        public let id: String
        public let name: String
        
        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    public typealias TreeTaskValue = CommonTreeNode<TaskItem>
}

#Preview {
    struct Playground:View {
        let menus: IdentifiedArrayOf<MenuSidebar.TreeMenuValue> = .init(uniqueElements: [
            .init(value: .init(
                id: UUID().uuidString,
                text: "menu1",
                mode: .selectable,
                icon: .init(name: "airpod.right")
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
        let tasks: IdentifiedArrayOf<TaskSelector.TreeTaskValue> = .init(uniqueElements: [
            .init(
                value: .init(id: UUID().uuidString, name: "任务1"),
                children: .init(uniqueElements: [
                    .init(value: .init(id: UUID().uuidString, name: "任务 1-1")),
                    .init(value: .init(id: UUID().uuidString, name: "任务 1-2"))
            ])),
            .init(value: .init(id: UUID().uuidString, name: "任务2")),
            .init(value: .init(id: UUID().uuidString, name: "任务3"))
        ])
        
        @State private var searchText = ""
        @State private var selectedMenu: MenuSidebar.SidebarMenuValue? = nil
        @State private var selectedTask: TaskSelector.TaskItem? = nil
        
        var body: some View {
            NavigationStack {
                NavigationLink {
                    TaskSelector(
                        menus: menus,
                        tasks: tasks,
                        selectedTask: $selectedTask,
                        selectedMenu: $selectedMenu,
                        searchText: $searchText
                    )
                } label: {
                    Text("go to select, current is: \(selectedTask?.name ?? "null")")
                }
                
            }
        }
    }
    
    return Playground()
}
