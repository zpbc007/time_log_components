//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/5/27.
//

import SwiftUI

extension KeyboardEditor {
    // 键盘上侧的弹窗内容
    struct ContentView: View {
        enum Field: Hashable {
            case title
            case desc
        }
        let titlePlaceholder: String
        let descPlaceholder: String
        let bgColor: Color
        @Binding var title: String
        @Binding var desc: String
        let action: () -> ActionView
        
        @FocusState private var focusedField: Field?
        
        var body: some View {
            VStack {
                TextField(titlePlaceholder, text: $title)
                    .focused($focusedField, equals: .title)
                    .font(.title3)
                
                TextField(descPlaceholder, text: $desc, axis: .vertical)
                    .lineLimit(2...10)
                    .focused($focusedField, equals: .desc)
                    .font(.callout)
                
                action()
            }
            .padding()
            .background(bgColor, in: .rect(topLeadingRadius: 10, topTrailingRadius: 10))
            .onAppear() {
                focusedField = .title
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State private var title = ""
        @State private var desc = ""
        @State private var tags: [String] = []
        
        var body: some View {
            ZStack(alignment: .bottom) {
                Color.black
                
                KeyboardEditor.ContentView(
                    titlePlaceholder: "任务名称",
                    descPlaceholder: "任务描述",
                    bgColor: .white,
                    title: $title,
                    desc: $desc
                ) {
                    VStack {
                        HStack {
                            ForEach(tags, id: \.self) { item in
                                Text(item)
                                    .onTapGesture {
                                        tags = tags.filter({ $0 != item })
                                    }
                            }
                        }
                        
                        HStack {
                            Menu {
                                ForEach(1..<100) { item in
                                    Button("tag-\(item)") {
                                        tags.append("tag-\(item)")
                                    }
                                }
                            } label: {
                                Image(systemName: "tag")
                            }
                            
                            Spacer()
                            
                            
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "arrow.up.circle")
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    return PreviewView()
}
