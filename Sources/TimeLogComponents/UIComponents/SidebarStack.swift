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
        sidebarToggleMinWidthPercent: CGFloat = 0.2,
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
                state = value.translation.width
            }
            .onEnded { value in
                let width = value.translation.width
                guard abs(width) >= sidebarToggleMinWidth else {
                    return
                }
                
                if showSidebar && width < 0 {
                    showSidebar = false
                }
                
                if !showSidebar && width > 0 {
                    showSidebar = true
                }
            }
    }
    
    private var xOffset: CGFloat {
        let value = showSidebar ? sidebarWidth + offset : offset
        if (value < 0) {
            return 0
        }
        
        return min(value, sidebarWidth)
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
                                    dragGesture.exclusively(
                                        before: TapGesture()
                                            .onEnded({ _ in
                                                showSidebar = false
                                            })
                                    )
                                )
                        } else if showSidebarDragArea {
                            HStack {
                                Color.white
                                    .opacity(0)
                                    .contentShape(Rectangle())
                                    .frame(width: 20)
                                    .gesture(dragGesture)
                                
                                Spacer()
                            }
                        }
                    }
                )
                .offset(x: xOffset)
                .animation(.easeInOut, value: xOffset)
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
                    .padding(.top)
                }.ignoresSafeArea()
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
