//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/12/28.
//

import SwiftUI

struct EmojiPicker: View {
    let activeColor: Color
    let items: [Value]
    @Binding var value: String?
    
    var body: some View {
        HStack {
            Spacer()
            
            ForEach(items) { item in
                SelectableEmoji(
                    code: item.code,
                    text: item.text,
                    color: activeColor,
                    selected: item.id == value
                ).onTapGesture {
                    value = item.id
                }
                
                if item != items.last {
                    Spacer()
                }
            }
            
            Spacer()
        }
    }
}

extension EmojiPicker {
    struct Value: Equatable, Identifiable {
        var id: String {
            value
        }
        
        let code: String
        let text: String
        let value: String
    }
}

extension EmojiPicker {
    struct SelectableEmoji: View {
        let code: String
        let text: String
        let color: Color
        let selected: Bool
        
        var body: some View {
            VStack {
                Text(code)
                    .padding(3)
                    .font(.largeTitle)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "checkmark.circle.fill")
                            .bold()
                            .foregroundStyle(color)
                            .opacity(selected ? 1 : 0)
                    }
                    .scaleEffect(selected ? 1.2 : 1)
                    .animation(.easeInOut, value: selected)
                
                Text(text)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var value: String? = nil
        
        var body: some View {
            EmojiPicker(
                activeColor: .blue,
                items: [
                    .init(code: "😟", text: "空虚", value: "1"),
                    .init(code: "😑", text: "一般", value: "2"),
                    .init(code: "😄", text: "充实", value: "3")
                ],
                value: $value
            )
        }
    }
    
    return Playground()
}

#Preview {
    EmojiPicker.SelectableEmoji(
        code: "😀",
        text: "充实",
        color: .red.opacity(0.8),
        selected: true
    )
}
