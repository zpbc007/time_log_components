//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/16.
//

import SwiftUI

// MARK: - active
extension View {
    @ViewBuilder 
    func active(if condition: Bool) -> some View {
        if condition { self }
    }
}

// MARK: - size
public struct SizePreferenceKey: PreferenceKey {
    public static var defaultValue: CGSize = .zero

    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let size = nextValue()
        
        value = .init(width: value.width + size.width, height: value.height + size.height)
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

extension View {
    public func contentSize() -> some View {
        modifier(SizeModifier())
    }
}


// MARK: - Preview
#Preview("active") {
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

#Preview("size") {
    struct Playground: View {
        @State private var childHeight1: CGFloat = 0
        @State private var child1: [String] = [UUID().uuidString, UUID().uuidString]
        
        @State private var childHeight2: CGFloat = 0
        @State private var child2: [String] = [UUID().uuidString]
        
        var body: some View {
            VStack {
                Text("childHeight1: \(childHeight1)")
                Button("append") {
                    child1.append(UUID().uuidString)
                }
                
                VStack {
                    ForEach(child1, id: \.self) { text in
                        Text(text)
                    }
                }
                .contentSize()
                .onPreferenceChange(SizePreferenceKey.self, perform: { value in
                    childHeight1 = value.height
                })
     
                Spacer()
                VStack {
                    ForEach(child2, id: \.self) { text in
                        Text(text)
                    }
                }
                .contentSize()
                .onPreferenceChange(SizePreferenceKey.self, perform: { value in
                    childHeight2 = value.height
                })
                Text("childHeight2: \(childHeight2)")
                Button("append") {
                    child2.append(UUID().uuidString)
                }
            }
        }
    }
    
    return Playground()
}
