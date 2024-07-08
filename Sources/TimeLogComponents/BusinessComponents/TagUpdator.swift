//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/8.
//

import SwiftUI

struct TagUpdator: View {
    let pageTitle: String
    @Binding var tagName: String
    let onSaveButtonTapped: () -> Void
    
    var body: some View {
        Form {
            VStack(alignment: .leading) {
                TextField("标签名称", text: $tagName)
                    .lineLimit(1)
                    .textInputAutocapitalization(.never)
                
                Text("用 标签/子标签 形式可创建多级标签")
                    .foregroundStyle(Color.gray)
                    .font(.subheadline)
                    .fontWeight(.thin)
            }
            .navigationTitle(pageTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onSaveButtonTapped()
                    } label: {
                        Label("保存", systemImage: "checkmark")
                            .labelStyle(.titleOnly)
                            .bold()
                    }
                }
            }
            .dismissBtn()
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var tagName = ""
        
        var body: some View {
            NavigationStack {
                TagUpdator(
                    pageTitle: "添加标签",
                    tagName: $tagName
                ) {
                    print("save!")
                }
            }
        }
    }
    
    return Playground()
}
