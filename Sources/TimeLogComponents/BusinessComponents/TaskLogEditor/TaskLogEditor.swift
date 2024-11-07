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
    
    @State private var bottomSize: CGSize = .zero
    
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
    
    private var durationString: String {
        var hourDiff = endTime.hour - startTime.hour
        var minuteDiff = endTime.minute - startTime.minute
        // 避免分钟出现负数
        if minuteDiff < 0 {
            hourDiff -= 1
            minuteDiff += 60
        }
        
        var result: String = ""
        
        if hourDiff != 0 {
            result += "\(hourDiff)小时"
        }
        if minuteDiff != 0 {
            result += "\(minuteDiff)分钟"
        }
        
        return result
    }
    
    public var body: some View {
        KeyboardEditor(
            bgColor: bgColor,
            dismiss: dismiss
        ) { size in
            VStack {
                if let onDeleteButtonTapped {
                    HStack {
                        Spacer()
                        
                        Button(role: .destructive, action: onDeleteButtonTapped) {
                            Image(systemName: "trash.circle")
                        }.font(.title2)
                    }
                }
                
                RichTextEditor(placeholder: "备注", maxHeight: size.height - bottomSize.height)
                    .border(.black)
                
                VStack {
                    self.timeSelector
                    
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
                }
                .contentSize()
                .onPreferenceChange(SizePreferenceKey.self, perform: { value in
                    bottomSize = value
                })
            }.padding()
        }.onChange(of: startTime) { _, newValue in
            if newValue < endTime {
                return
            }
            
            endTime = startTime.addingTimeInterval(30 * 60)
        }.onChange(of: endTime) { _, newValue in
            if startTime < newValue {
                return
            }
            
            startTime = endTime.addingTimeInterval(-30 * 60)
        }
    }
    
    @ViewBuilder
    private var timeSelector: some View {
        HStack {
            Image(systemName: "clock")
            HourMinutePicker(selection: $startTime)
            Spacer()
            Image(systemName: "arrow.right")
            HourMinutePicker(selection: $endTime)
            Text(self.durationString)
                .foregroundStyle(.secondary)
            Spacer()
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
                
//                if showEditor {
//                    TaskLogEditor(
//                        fontColor: .primary,
//                        activeFontColor: .blue,
//                        bgColor: .white,
//                        selectedTaskName: nil,
//                        startTime: $startTime,
//                        endTime: $endTime
//                    ) {
//                        print("onSelectTaskButtonTapped")
//                    } onSendButtonTapped: {
//                        print("onSendButtonTapped")
//                    } dismiss: {
//                        showEditor = false
//                    } onDeleteButtonTapped: {
//                        print("delete")
//                    }
//                    .environmentObject(editorVM)
//                }
                
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
    
    return Playground()
}
