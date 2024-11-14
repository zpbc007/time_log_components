//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/20.
//

import SwiftUI
import IdentifiedCollections

public struct EventSelector: View {
    let categories: IdentifiedArrayOf<MenuSidebar.TreeMenuValue>
    let events: IdentifiedArrayOf<EventTreeValue>
    
    @Binding private var selectedEvent: EventItem?
    @Binding var selectedCategory: MenuSidebar.SidebarMenuValue?
    
    @State private var searchText: String = ""
    @State private var showCategoryMenu = false
    
    private var filteredEvents: IdentifiedArrayOf<EventTreeValue> {
        if (searchText.isEmpty) {
            return events
        }
        
        return CommonTreeNode.filter(tree: events) { node in
            node.name.contains(searchText)
        }
    }
    
    public init(
        categories: IdentifiedArrayOf<MenuSidebar.TreeMenuValue>,
        events: IdentifiedArrayOf<EventTreeValue>,
        selectedEvent: Binding<EventItem?>,
        selectedCategory: Binding<MenuSidebar.SidebarMenuValue?>
    ) {
        self.categories = categories
        self.events = events
        self._selectedEvent = selectedEvent
        self._selectedCategory = selectedCategory
    }
    
    public var body: some View {
        Form {
            TextField("搜索", text: $searchText)
            
            Section(header: self.EventsHeader) {
                if filteredEvents.isEmpty {
                    self.EmptyEventView
                } else {
                    List {
                        OutlineGroup(filteredEvents, children: \.children) { item in
                            Group {
                                HStack {
                                    if item.id == selectedEvent?.id {
                                        Text(item.value.name)
                                            .lineLimit(1)
                                            .foregroundStyle(.selection)
                                    } else {
                                        Text(item.value.name)
                                            .lineLimit(1)
                                            .foregroundStyle(.primary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedEvent = item.value
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showCategoryMenu) {
            NavigationStack {
                TaskSearchMenu.Sheet(menus: categories, selection: $selectedCategory)
            }
        }
        .onChange(of: selectedCategory) { _, _ in
            searchText = ""
        }
    }
    
    @ViewBuilder
    private var EventsHeader: some View {
        Button {
            showCategoryMenu = true
        } label: {
            HStack {
                if let selectedCategory {
                    MenuSidebar.MenuCellContent(selectedCategory, addSpacer: false)
                } else {
                    Text("所有分类")
                }
                
                Image(systemName: "chevron.right")
                
                Spacer()
            }
            .font(.caption)
        }
    }
    
    @ViewBuilder
    private var EmptyEventView: some View {
        HStack {
            Spacer()
            Text("无事件")
            Spacer()
        }
    }
}

extension EventSelector {
    public struct EventItem: Equatable, Identifiable {
        public let id: String
        public let name: String
        
        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    public typealias EventTreeValue = CommonTreeNode<EventItem>
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
        let tasks: IdentifiedArrayOf<EventSelector.EventTreeValue> = .init(uniqueElements: [
            .init(value: .init(
                id: UUID().uuidString,
                name: "长 title 任务2长 title 任务2长 title 任务2长 title 任务2长 title 任务2长 title 任务2"
            )),
            .init(value: .init(id: UUID().uuidString, name: "任务3")),
            .init(value: .init(id: UUID().uuidString, name: "任务4")),
            .init(value: .init(id: UUID().uuidString, name: "任务5")),
            .init(value: .init(id: UUID().uuidString, name: "任务6")),
            .init(value: .init(id: UUID().uuidString, name: "任务7")),
            .init(value: .init(id: UUID().uuidString, name: "任务8")),
            .init(value: .init(id: UUID().uuidString, name: "任务9")),
            .init(value: .init(id: UUID().uuidString, name: "任务10")),
            .init(value: .init(id: UUID().uuidString, name: "任务11")),
            .init(value: .init(id: UUID().uuidString, name: "任务12")),
            .init(value: .init(id: UUID().uuidString, name: "任务13")),
            .init(value: .init(id: UUID().uuidString, name: "任务14")),
            .init(value: .init(id: UUID().uuidString, name: "任务15")),
            .init(value: .init(id: UUID().uuidString, name: "任务16")),
            .init(value: .init(id: UUID().uuidString, name: "任务17")),
        ])
        
        @State private var selectedMenu: MenuSidebar.SidebarMenuValue? = nil
        @State private var selectedTask: EventSelector.EventItem? = nil
        
        var body: some View {
            NavigationStack {
                NavigationLink {
                    EventSelector(
                        categories: menus,
                        events: tasks,
                        selectedEvent: $selectedTask,
                        selectedCategory: $selectedMenu
                    ).navigationTitle("测试 Title")
                } label: {
                    Text("go to select, current is: \(selectedTask?.name ?? "null")")
                }
                
            }
        }
    }
    
    return Playground()
}
