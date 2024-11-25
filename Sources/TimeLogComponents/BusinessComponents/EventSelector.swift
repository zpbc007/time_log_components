//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/20.
//

import SwiftUI
import IdentifiedCollections

public struct EventSelector {
    public struct MainView<CategoryEditor: View>: View {
        let categories: [CategoryList.Item]
        let events: IdentifiedArrayOf<EventSelector.EventTreeValue>
        let startAction: Optional<() -> Void>
        let editCategoryAction: Optional<(CategoryList.Item) -> Void>
        let addEventAction: () -> Void
        let buildCategoryEditor: () -> CategoryEditor
        
        @Binding var selectedEvent: EventItem?
        @Binding var selectedCategory: CategoryList.Item?
        @Binding var showCategoryEditor: Bool
        
        @State private var searchText: String = ""
        @State private var showCategoryMenu = false
        
        private var filteredEvents: IdentifiedArrayOf<EventSelector.EventTreeValue> {
            if (searchText.isEmpty) {
                return events
            }
            
            return CommonTreeNode.filter(tree: events) { node in
                node.name.contains(searchText)
            }
        }
        
        public init(
            categories: [CategoryList.Item],
            events: IdentifiedArrayOf<EventSelector.EventTreeValue>,
            selectedEvent: Binding<EventItem?>,
            selectedCategory: Binding<CategoryList.Item?>,
            showCategoryEditor: Binding<Bool>,
            addEventAction: @escaping () -> Void,
            startAction: Optional<() -> Void>,
            editCategoryAction: Optional<(CategoryList.Item) -> Void>,
            @ViewBuilder
            buildCategoryEditor: @escaping () -> CategoryEditor
        ) {
            self.categories = categories
            self.events = events
            self._selectedEvent = selectedEvent
            self._selectedCategory = selectedCategory
            self._showCategoryEditor = showCategoryEditor
            self.startAction = startAction
            self.addEventAction = addEventAction
            self.editCategoryAction = editCategoryAction
            self.buildCategoryEditor = buildCategoryEditor
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
                    ZStack {
                        CategoryList(
                            categories: categories,
                            tapAction: { item in
                                withAnimation {
                                    selectedCategory = item
                                    showCategoryMenu = false
                                }
                            },
                            editAction: self.editCategoryAction
                        )
                        
                        if showCategoryEditor {
                            buildCategoryEditor()
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                showCategoryEditor = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .dismissBtn()
                    .navigationTitle("事件分类")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: addEventAction) {
                            Image(systemName: "plus")
                        }
                        
                        if let startAction {
                            Button(action: startAction) {
                                Image(systemName: "restart")
                            }.disabled(selectedEvent == nil)
                        }
                    }
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
                        selectedCategory.color
                            .clipShape(Circle())
                            .frame(width: 10, height: 10)
                            
                        Text(selectedCategory.name)
                            .lineLimit(2)
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
        let categories: [CategoryList.Item] = [
            .init(id: UUID().uuidString, name: "学习投入投入", color: .red, count: 5),
            .init(id: UUID().uuidString, name: "兴趣投入", color: .green, count: 3),
            .init(id: UUID().uuidString, name: "语言学习", color: .blue, count: 5),
            .init(id: UUID().uuidString, name: "工作投入", color: .cyan, count: 5),
            .init(id: UUID().uuidString, name: "健康投入超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长", color: .red, count: 5),
            .init(id: UUID().uuidString, name: "运动投入", color: .green, count: 5),
            .init(id: UUID().uuidString, name: "感情投入", color: .brown, count: 5),
            .init(id: UUID().uuidString, name: "感情投入", color: .black, count: 5)
        ]
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
        
        @State private var selectedCategory: CategoryList.Item? = nil
        @State private var selectedEvent: EventSelector.EventItem? = nil
        @State private var hasStart = false
        @State private var hasCategoryEdit = false
        @State private var showCategoryEditor = false
        
        private var startAction: Optional<() -> Void> {
            guard hasStart else {
                return nil
            }
            
            return {
                print("start: \(selectedEvent?.name ?? "")")
            }
        }
        
        private var editCategoryAction: Optional<(CategoryList.Item) -> Void> {
            guard hasCategoryEdit else {
                return nil
            }
            
            return { item in
                print("edit: \(item.name)")
            }
        }
        
        var body: some View {
            NavigationStack {
                VStack {
                    Button("hasStart: \(hasStart ? "yes" : "no")") {
                        hasStart.toggle()
                    }
                    
                    Button("hasEdit: \(hasCategoryEdit ? "yes" : "no")") {
                        hasCategoryEdit.toggle()
                    }
                    
                    NavigationLink {
                        EventSelector.MainView(
                            categories: categories,
                            events: tasks,
                            selectedEvent: $selectedEvent,
                            selectedCategory: $selectedCategory,
                            showCategoryEditor: $showCategoryEditor,
                            addEventAction: {
                                print("add event")
                            },
                            startAction: self.startAction,
                            editCategoryAction: self.editCategoryAction,
                            buildCategoryEditor: {
                                Text("editor")
                            }
                        ).navigationTitle("测试 Title")
                    } label: {
                        Text("go to select, current is: \(selectedEvent?.name ?? "null")")
                    }
                }
            }
        }
    }
    
    return Playground()
}
