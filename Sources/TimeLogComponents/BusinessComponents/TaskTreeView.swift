//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/6/24.
//

import SwiftUI
import IdentifiedCollections

public struct TaskTreeView: View {
    public struct TaskItem: Equatable, Identifiable {
        public let id: String
        public let name: String
        public let done: Bool
        
        public init(id: String, name: String, done: Bool) {
            self.id = id
            self.name = name
            self.done = done
        }
    }
    public typealias TaskInTree = CommonTreeNode<TaskItem>
    
    let taskTree: IdentifiedArrayOf<TaskInTree>
    let isEditMode: Bool
    let startButtonColor: Color
    let onTaskTapped: (String) -> Void
    let onTaskToggle: ((String, Bool) -> Void)?
    let onTaskStart: ((String) -> Void)?
    let onTaskDelete: ((String) -> Void)?
    
    public init(
        taskTree: IdentifiedArrayOf<TaskInTree>,
        startButtonColor: Color,
        onTaskTapped: @escaping (String) -> Void
    ) {
        self.taskTree = taskTree
        self.startButtonColor = startButtonColor
        self.isEditMode = false
        self.onTaskTapped = onTaskTapped
        self.onTaskToggle = nil
        self.onTaskStart = nil
        self.onTaskDelete = nil
    }
    
    public init(
        taskTree: IdentifiedArrayOf<TaskInTree>,
        startButtonColor: Color,
        onTaskTapped: @escaping (String) -> Void,
        onTaskToggle: @escaping (String, Bool) -> Void,
        onTaskStart: @escaping (String) -> Void,
        onTaskDelete: @escaping (String) -> Void
    ) {
        self.taskTree = taskTree
        self.startButtonColor = startButtonColor
        self.isEditMode = true
        self.onTaskTapped = onTaskTapped
        self.onTaskToggle = onTaskToggle
        self.onTaskStart = onTaskStart
        self.onTaskDelete = onTaskDelete
    }
    
    public var body: some View {
        if taskTree.isEmpty {
            emptyTaskView
        } else {
            OutlineGroup(taskTree, children: \.children) { node in
                if isEditMode {
                    editTaskCell(node: node)
                } else {
                    readonlyTaskCell(node: node)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    @ViewBuilder
    private var emptyTaskView: some View {
        HStack {
            Spacer()
            Text("无任务")
            Spacer()
        }
    }
    
    @ViewBuilder
    private func editTaskCell(node: TaskInTree) -> some View {
        TaskCell(
            name: node.value.name,
            finished: .init(
                get: {
                    node.value.done
                }, set: { value in
                    onTaskToggle?(node.value.id, value)
                }
            )
        )
        .equatable()
        .onTapGesture {
            onTaskTapped(node.value.id)
        }
        .swipeActions(edge: .trailing) {
            if !node.value.done { // 未完成任务，展示开始入口
                Button {
                    onTaskStart?(node.id)
                } label: {
                    Image(systemName: "restart")
                }
                .tint(startButtonColor)
            }
            
            Button(role: .destructive) {
                onTaskDelete?(node.id)
            } label: {
                Image(systemName: "trash")
            }
        }
    }
    
    @ViewBuilder
    private func readonlyTaskCell(node: TaskInTree) -> some View {
        TaskCell(name: node.value.name, finished: node.value.done)
            .equatable()
            .onTapGesture {
                onTaskTapped(node.id)
            }
    }
}

#Preview("edit") {
    List {
        TaskTreeView(
            taskTree: .init(uniqueElements: [
                .init(value: .init(id: "task1", name: "task1", done: false)),
                .init(value: .init(id: "task2", name: "task2", done: true)),
                .init(
                    value: .init(id: "task3", name: "task3", done: false),
                    children: .init(uniqueElements: [
                        .init(value: .init(id: "task3-1", name: "task3-1", done: false)),
                        .init(value: .init(id: "task3-2", name: "task3-2", done: false)),
                        .init(value: .init(id: "task3-3", name: "task3-3", done: true))
                    ])
                )
            ]),
            startButtonColor: .blue,
            onTaskTapped: { id in
                print("tapped \(id)")
            },
            onTaskToggle: { id, finished in
                print("toggle \(id), \(finished)")
            },
            onTaskStart: { id in
                print("start \(id)")
            },
            onTaskDelete: { id in
                print("delete \(id)")
            }
        )
    }
}

#Preview("readonly") {
    List {
        TaskTreeView(
            taskTree: .init(uniqueElements: [
                .init(value: .init(id: "task1", name: "task1", done: false)),
                .init(value: .init(id: "task2", name: "task2", done: true)),
                .init(
                    value: .init(id: "task3", name: "task3", done: false),
                    children: .init(uniqueElements: [
                        .init(value: .init(id: "task3-1", name: "task3-1", done: false)),
                        .init(value: .init(id: "task3-2", name: "task3-2", done: false)),
                        .init(value: .init(id: "task3-3", name: "task3-3", done: true))
                    ])
                )
            ]),
            startButtonColor: .blue
        ) { id in
            print("tapped \(id)")
        }
    }
}
