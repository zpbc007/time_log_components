//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/3.
//

import SwiftUI

public struct CheckListUpdator: View {
    let pageTitle: String
    @Binding var name: String
    @Binding var color: Color
    let onSaveButtonTapped: () -> Void
    
    public init(
        pageTitle: String,
        name: Binding<String>,
        color: Binding<Color>,
        onSaveButtonTapped: @escaping () -> Void
    ) {
        self.pageTitle = pageTitle
        self._name = name
        self._color = color
        self.onSaveButtonTapped = onSaveButtonTapped
    }
    
    public var body: some View {
        Form {
            TextField("清单名称", text: $name)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            ColorPicker("清单颜色", selection: $color)
        }
        .navigationTitle(pageTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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

#Preview {
    struct Playground: View {
        @State private var name = ""
        @State private var color = Color.red
        
        var body: some View {
            NavigationStack {
                CheckListUpdator(
                    pageTitle: "添加清单",
                    name: $name,
                    color: $color
                ) {
                    print("save!!!")
                }
            }
        }
    }
    
    return Playground()
}
