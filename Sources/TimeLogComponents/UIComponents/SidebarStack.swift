//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/5/30.
//

import SwiftUI

public struct SideBarStack<SidebarContent: View, Content: View>: View {
    let sidebarContent: SidebarContent
    let mainContent: Content
    // 侧边栏宽度占比
    let sidebarWidth: CGFloat
    // 最小移动百分比
    let sidebarToggleMinWidth: CGFloat
    // sidebar 是否展示
    @Binding var showSidebar: Bool
    // 拖拽响应区是否展示
    @Binding var showSidebarDragArea: Bool
    
    // 滑动偏移量
    @GestureState private var offset: CGFloat = 0
    
    public init(
        sidebarWidthPercent: CGFloat = 0.8,
        sidebarToggleMinWidthPercent: CGFloat = 0.5,
        showSidebar: Binding<Bool>,
        showSidebarDragArea: Binding<Bool>,
        @ViewBuilder sidebar: () -> SidebarContent,
        @ViewBuilder content: () -> Content
    ) {
        let screenWidth = UIScreen.main.bounds.width
        
        self.sidebarWidth = screenWidth * sidebarWidthPercent
        self.sidebarToggleMinWidth = screenWidth * sidebarToggleMinWidthPercent * sidebarWidthPercent
        self._showSidebar = showSidebar
        self._showSidebarDragArea = showSidebarDragArea
        sidebarContent = sidebar()
        mainContent = content()
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($offset) { value, state, _ in
                if (value.translation.width >= 0 || showSidebar) {
                    state = value.translation.width
                }
            }
            .onEnded { value in
                if value.translation.width >= sidebarToggleMinWidth {
                    showSidebar = true
                } else {
                    showSidebar = false
                }
            }
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            sidebarContent
                .frame(width: sidebarWidth, alignment: .center)
            
            mainContent
                .overlay (
                    Group {
                        if showSidebar {
                            Color.white
                                .opacity(0)
                                .contentShape(Rectangle())
                                .gesture(
                                    TapGesture()
                                        .onEnded({ _ in
                                            showSidebar = false
                                        })
                                        .exclusively(before: dragGesture)
                                )
                        } else if showSidebarDragArea {
                            HStack {
                                Color.white
                                    .opacity(0)
                                    .contentShape(Rectangle())
                                    .frame(width: 10)
                                    .gesture(dragGesture)
                                
                                Spacer()
                            }
                        }
                    }
                )
                .offset(x: showSidebar ? sidebarWidth + offset : offset)
                .animation(.easeInOut, value: showSidebar ? sidebarWidth + offset : offset)
        }
    }
}

#Preview {
    struct SideBarStack_Playground: View {
        @State var showSidebar = false
        @State var showSidebarDragArea = true
        
        var body: some View {
            SideBarStack(
                showSidebar: $showSidebar,
                showSidebarDragArea: $showSidebarDragArea
            ) {
                ZStack {
                    Color.blue
                        .ignoresSafeArea()
                    
                    VStack {
                        List {
                            Text("Content")
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            Text("Content")
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        
                        Text("Bottom")
                    }
                }
            } content: {
                NavigationStack {
                    List {
                        Button("Toggle sidebar") {
                            showSidebar.toggle()
                        }
                        
                        Button("Toggle SidebarDragArea, current: \(String(describing: showSidebarDragArea))") {
                            showSidebarDragArea.toggle()
                        }
                        
                        ForEach(1..<50) { item in
                            Text("Content-\(item)")
                        }.onDelete(perform: { indexSet in
                            
                        })
                    }
                }
            }
        }
    }
    
    return SideBarStack_Playground()
}
