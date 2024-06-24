//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/24.
//

import SwiftUI

public struct TaskCell: View {
    enum Mode {
        case readonly
        case edit
        
        var isEdit: Bool {
            switch self {
            case .edit:
                return true
            default:
                return false
            }
        }
    }
    let mode: Mode
    let name: String
    @Binding var finished: Bool
    
    public init(name: String, finished: Binding<Bool>) {
        self.name = name
        self._finished = finished
        self.mode = .edit
    }
    
    public init(name: String, finished: Bool) {
        self.name = name
        self._finished = .constant(finished)
        self.mode = .readonly
    }
    
    public var body: some View {
        if mode.isEdit {
            editCell
        } else {
            readonlyCell
        }
    }
    
    @ViewBuilder
    private var editCell: some View {
        HStack {
            Toggle(name, isOn: $finished)
                .lineLimit(1)
                .strikethrough(finished)
                .toggleStyle(.checkmark)
            
            Spacer()
        }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private var readonlyCell: some View {
        HStack {
            Text(name)
                .lineLimit(1)
                .strikethrough(finished)
            Spacer()
        }.contentShape(Rectangle())
    }
}

#Preview("edit view") {
    struct Playground: View {
        @State private var finished = false
        var body: some View {
            List {
                TaskCell(name: "任务xxx", finished: $finished)
            }
        }
    }
    
    return Playground()
}

#Preview("readonly view") {
    List {
        TaskCell(name: "任务xxx", finished: false)
        TaskCell(name: "任务xxx", finished: true)
    }
}
