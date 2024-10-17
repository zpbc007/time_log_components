//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/16.
//

import SwiftUI

extension View {
    @ViewBuilder 
    func active(if condition: Bool) -> some View {
        if condition { self }
    }
}

#Preview {
    struct Playground: View {
        @State private var active = false
        
        var body: some View {
            VStack {
                Text("xxx")
                    .active(if: active)
                
                Button("toggle") {
                    active.toggle()
                }
            }
        }
    }
    
    return Playground()
}
