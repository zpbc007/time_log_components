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

// MARK: - Scroll position
public struct ScrollOffsetPreferenceKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0

    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ScrollOffsetModifier: ViewModifier {
    let coordinateSpace: CoordinateSpace
    
    private var scrollOffsetView: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: ScrollOffsetPreferenceKey.self, 
                value: geometry.frame(in: coordinateSpace).minY
            )
        }
    }

    func body(content: Content) -> some View {
        content.background(scrollOffsetView)
    }
}

extension View {
    public func scrollOffset(coordinateSpace: CoordinateSpace) -> some View {
        modifier(ScrollOffsetModifier(coordinateSpace: coordinateSpace))
    }
}

#Preview("scrollOffset") {
    struct Playground: View {
        @State private var offset: CGFloat = 0
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text("offset: \(offset)")
                }.frame(height: 100)
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<30, id: \.self) { item in
                            HStack {
                                Text("item - \(item)")
                                
                                Spacer()
                                
                                Text("content")
                            }
                            .padding(.horizontal)
                            .frame(height: 100)
                            .border(.blue)
                        }
                    }
                    .scrollOffset(coordinateSpace: .named("test"))
                }
                .coordinateSpace(name: "test")
            }.onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: { value in
                offset = value
            })
        }
    }
    
    return Playground()
}
