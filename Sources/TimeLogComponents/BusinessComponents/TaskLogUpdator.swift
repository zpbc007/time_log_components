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
        let categories: [CategoryList.Item] = [
            .init(id: UUID().uuidString, name: "学习投入投入", color: .red, count: 5),
            .init(id: UUID().uuidString, name: "兴趣投入", color: .green, count: 3),
            .init(id: UUID().uuidString, name: "语言学习", color: .blue, count: 5),
            .init(id: UUID().uuidString, name: "工作投入", color: .cyan, count: 5),
            .init(id: UUID().uuidString, name: "健康投入超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长", color: .red, count: 5),
            .init(id: UUID().uuidString, name: "运动投入", color: .green, count: 5),
            .init(id: UUID().uuidString, name: "感情投入", color: .brown, count: 5),
            .init(id: UUID().uuidString, name: "感情投入", color: .black, count: 5)
        ]
        let tasks: IdentifiedArrayOf<EventSelector.EventTreeValue> = .init(uniqueElements: [
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
        
        @State private var selectedCategory: CategoryList.Item? = nil
        @State private var selectedEvent: EventSelector.EventItem? = nil
        @State private var categoryEditorStatus: EventSelector.CategoryEditorStatus = .hidden
        @State private var showCategoryMenu: Bool = false

        var body: some View {
            NavigationStack {
                VStack {
                    NavigationLink {
                        EventSelector.MainView(
                            categories: categories,
                            events: tasks,
                            selectedEvent: $selectedEvent,
                            selectedCategory: $selectedCategory,
                            categoryEditorStatus: $categoryEditorStatus,
                            showCategoryMenu: $showCategoryMenu,
                            addEventAction: {
                               print("add event")
                            },
                            pickEventAction: {
                                print("pick event")
                            },
                            startAction: {
                                print("start")
                            },
                            buildCategoryEditor: {
                               Text("editor")
                           }
                        )
                    } label: {
                        HStack {
                            Text("任务")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("task: \(selectedEvent?.name ?? "empty")")
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
