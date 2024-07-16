//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/16.
//

import SwiftUI
import IdentifiedCollections

public struct TaskLogAddEditor: View {
    public typealias CheckListInfo = TimeLogSelectable
    
    let fontColor: Color
    let activeFontColor: Color
    let bgColor: Color
    let checklists: IdentifiedArrayOf<CheckListInfo>
    @Binding var selectedCheckList: String?
    @Binding var startTime: Date
    @Binding var endTime: Date
    let onSendButtonTapped: () -> Void
    let dismiss: () -> Void
    
    public init(
        fontColor: Color,
        activeFontColor: Color,
        bgColor: Color,
        checklists: IdentifiedArrayOf<CheckListInfo>,
        selectedCheckList: Binding<String?>,
        startTime: Binding<Date>,
        endTime: Binding<Date>,
        onSendButtonTapped: @escaping () -> Void,
        dismiss: @escaping () -> Void
    ) {
        self.fontColor = fontColor
        self.activeFontColor = activeFontColor
        self.bgColor = bgColor
        self.checklists = checklists
        self._selectedCheckList = selectedCheckList
        self._startTime = startTime
        self._endTime = endTime
        self.onSendButtonTapped = onSendButtonTapped
        self.dismiss = dismiss
    }
    
    var isValid: Bool {
        startTime < endTime && selectedCheckList != nil
    }
    
    public var body: some View {
        KeyboardEditor(
            bgColor: bgColor,
            dismiss: dismiss
        ) {
            VStack {
                RichTextEditor()
                    .frame(maxHeight: 200)
                
                VStack {
                    DatePicker(
                        "开始时间",
                        selection: $startTime
                    )
                    DatePicker(
                        "结束时间",
                        selection: $endTime
                    )
                    
                    HStack {
                        TaskEditor_Common.CheckListSelector(
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
                    }
                    
                    
                }
                .padding(.horizontal)
                .clipped()
            }
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
        @StateObject var editorVM: RichTextEditor.ViewModel = .init(focused: true, roundedTopCorners: true)
        @State private var showEditor = false
        @State private var startTime: Date = .now
        @State private var endTime: Date = .now
        
        var body: some View {
            ZStack {
                Color.gray
                
                Button("click") {
                    showEditor.toggle()
                }
                
                if showEditor {
                    TaskLogAddEditor(
                        fontColor: .primary,
                        activeFontColor: .blue,
                        bgColor: .white,
                        checklists: checklists,
                        selectedCheckList: $selectedCheckList,
                        startTime: $startTime,
                        endTime: $endTime,
                        onSendButtonTapped: {
                            print("send")
                        }
                    ) {
                        showEditor = false
                    }.environmentObject(editorVM)
                }
            }
            
        }
    }
    
    return Playground()
}
