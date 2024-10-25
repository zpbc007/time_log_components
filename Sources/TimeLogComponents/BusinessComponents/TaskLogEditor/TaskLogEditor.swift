//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/16.
//

import SwiftUI
import IdentifiedCollections

public struct TaskLogEditor: View {
    public typealias CheckListInfo = TimeLogSelectable
    
    let fontColor: Color
    let activeFontColor: Color
    let bgColor: Color
    let selectedTaskName: String?
    @Binding var startTime: Date
    @Binding var endTime: Date
    let onSelectTaskButtonTapped: () -> Void
    let onSendButtonTapped: () -> Void
    let dismiss: () -> Void
    let onDeleteButtonTapped: (() -> Void)?
    
    public init(
        fontColor: Color,
        activeFontColor: Color,
        bgColor: Color,
        selectedTaskName: String?,
        startTime: Binding<Date>,
        endTime: Binding<Date>,
        onSelectTaskButtonTapped: @escaping () -> Void,
        onSendButtonTapped: @escaping () -> Void,
        dismiss: @escaping () -> Void,
        onDeleteButtonTapped: (() -> Void)? = nil
    ) {
        self.fontColor = fontColor
        self.activeFontColor = activeFontColor
        self.bgColor = bgColor
        self.selectedTaskName = selectedTaskName
        self._startTime = startTime
        self._endTime = endTime
        self.onSelectTaskButtonTapped = onSelectTaskButtonTapped
        self.onSendButtonTapped = onSendButtonTapped
        self.dismiss = dismiss
        self.onDeleteButtonTapped = onDeleteButtonTapped
    }
    
    var isValid: Bool {
        startTime < endTime && selectedTaskName != nil
    }
    
    public var body: some View {
        KeyboardEditor(
            bgColor: bgColor,
            dismiss: dismiss
        ) {
            VStack {
                if let onDeleteButtonTapped {
                    HStack {
                        Spacer()
                        
                        Button(role: .destructive, action: onDeleteButtonTapped) {
                            Image(systemName: "trash.circle")
                        }.font(.title2)
                    }
                }
                
                RichTextEditor(maxHeight: 260)
                
                DatePicker(
                    "开始时间",
                    selection: $startTime
                )
                DatePicker(
                    "结束时间",
                    selection: $endTime
                )
                
                HStack {
                    Button(
                        action: onSelectTaskButtonTapped,
                        label: {
                            HStack(alignment: .center) {
                                Text(selectedTaskName ?? "选择任务")
                                Image(systemName: "chevron.down")
                            }
                        }
                    ).tint(selectedTaskName == nil ? fontColor : activeFontColor)
                    
                    Spacer()
                    
                    TaskEditor_Common.ConfirmButton(
                        fontColor: fontColor,
                        activeFontColor: activeFontColor,
                        action: onSendButtonTapped,
                        isValid: isValid
                    )
                }
                .padding(.top)
            }.padding()
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
        @State private var selectedCheckList: String? = nil
        @StateObject var editorVM: RichTextEditor.ViewModel = .init()
        @State private var showEditor = false
        @State private var startTime: Date = .now
        @State private var endTime: Date = .now
        
        var body: some View {
            ZStack {
//                Color.gray
                
                Button("click") {
                    showEditor.toggle()
                }
                
                if showEditor {
                    TaskLogEditor(
                        fontColor: .primary,
                        activeFontColor: .blue,
                        bgColor: .white,
                        selectedTaskName: nil,
                        startTime: $startTime,
                        endTime: $endTime
                    ) {
                        print("onSelectTaskButtonTapped")
                    } onSendButtonTapped: {
                        print("onSendButtonTapped")
                    } dismiss: {
                        showEditor = false
                    } onDeleteButtonTapped: {
                        print("delete")
                    }
                    .environmentObject(editorVM)
                }
            }
            
        }
    }
    
    return Playground()
}
