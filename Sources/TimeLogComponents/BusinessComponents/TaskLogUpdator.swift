//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/12.
//

import SwiftUI
import IdentifiedCollections

public struct TaskLogUpdator: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    public init(
        startTime: Binding<Date>,
        endTime: Binding<Date>
    ) {
        self._startTime = startTime
        self._endTime = endTime
    }
    
    public var body: some View {
        VStack {
            DatePicker(
                "开始时间",
                selection: $startTime
            )
            DatePicker(
                "结束时间",
                selection: $startTime
            )
            
            RichTextEditor(placeholder: "备注")
        }
    }
}

#Preview {
    struct Playground: View {
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
        
        @State private var startTime: Date = .now
        @State private var endTime: Date = .now
        @StateObject private var editorVM = RichTextEditor.ViewModel()
        
        @State private var searchText = ""
        @State private var selectedMenu: MenuSidebar.SidebarMenuValue? = nil
        @State private var selectedTask: TaskSelector.TaskItem? = nil
        
        var body: some View {
            NavigationStack {
                VStack {
                    NavigationLink {
                        TaskSelector(
                            menus: menus,
                            tasks: tasks,
                            selectedTask: $selectedTask,
                            selectedMenu: $selectedMenu,
                            searchText: $searchText
                        )
                    } label: {
                        HStack {
                            Text("任务")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("task: \(selectedTask?.name ?? "empty")")
                        }
                    }
                    
                    TaskLogUpdator(
                        startTime: $startTime,
                        endTime: $endTime
                    ).environmentObject(editorVM)
                }.padding()
            }
        }
    }
    
    return Playground()
}
