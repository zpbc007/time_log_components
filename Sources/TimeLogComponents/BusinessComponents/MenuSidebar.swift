//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/5/31.
//

import SwiftUI
import IdentifiedCollections

public struct MenuSidebar: View {
    let bgColor: Color
    let activeFontColor: Color
    let fontColor: Color
    let deleteButtonColor: Color
    let editButtonColor: Color
    let menus: MenuValues
    @Binding var selection: SidebarMenuValue?
    let onSidebarMenuEdit: (String) -> Void
    let onSidebarMenuDelete: (String) -> Void
    let onBottomMenuTapped: (String) -> Void
    
    public init(
        bgColor: Color,
        activeFontColor: Color,
        fontColor: Color,
        deleteButtonColor: Color,
        editButtonColor: Color,
        menus: MenuValues,
        selection: Binding<SidebarMenuValue?>,
        onSidebarMenuEdit: @escaping (String) -> Void,
        onSidebarMenuDelete: @escaping (String) -> Void,
        onBottomMenuTapped: @escaping (String) -> Void
    ) {
        self.bgColor = bgColor
        self.activeFontColor = activeFontColor
        self.fontColor = fontColor
        self.deleteButtonColor = deleteButtonColor
        self.editButtonColor = editButtonColor
        self.menus = menus
        self._selection = selection
        self.onSidebarMenuEdit = onSidebarMenuEdit
        self.onSidebarMenuDelete = onSidebarMenuDelete
        self.onBottomMenuTapped = onBottomMenuTapped
    }
    
    public var body: some View {
        ZStack {
            bgColor
                .ignoresSafeArea()
            
            VStack {
                List {
                    OutlineGroup(menus.sidebarMenus, children: \.children) { item in
                        if item.value.mode == .readonly {
                            MenuCellContent(item.value)
                                .contentShape(Rectangle())
                        }
                        
                        if item.value.mode == .selectable {
                            MenuCellContent(item.value)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selection = item.value
                                }
                                .foregroundStyle(
                                    item.id == self.selection?.id
                                    ? activeFontColor
                                    : fontColor
                                )
                        }
                        
                        if item.value.mode == .editable  {
                            MenuCellContent(item.value)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selection = item.value
                                }
                                .foregroundStyle(
                                    item.id == self.selection?.id
                                    ? activeFontColor
                                    : fontColor
                                )
                                .swipeActions(allowsFullSwipe: false) {
                                    HStack {
                                        Button {
                                            onSidebarMenuDelete(item.value.id)
                                        } label: {
                                            Label("删除", systemImage: "trash")
                                        }
                                        .tint(deleteButtonColor)
                                        
                                        Button {
                                            onSidebarMenuEdit(item.value.id)
                                        } label: {
                                            Label("编辑", systemImage: "pencil.line")
                                        }
                                        .tint(editButtonColor)
                                    }
                                }
                        }
                    }
                    .foregroundStyle(fontColor)
                    .fontWeight(.bold)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                
                Spacer()
                
                HStack {
                    Menu {
                        bottomMenus(menus.bottomAddMenus)
                    } label: {
                        Label("添加", systemImage: "plus")
                    }
                    
                    Spacer()

                    Menu {
                        bottomMenus(menus.bottomMoreMenus)
                    } label: {
                        Label("更多", systemImage: "ellipsis")
                    }
                }
                .padding(.horizontal)
            }
        }
        .tint(fontColor)
    }
    
    @ViewBuilder
    private func bottomMenus(
        _ menus: [BottomMenuValue]
    ) -> some View {
        ForEach(menus) { item in
            Button {
                onBottomMenuTapped(item.id)
            } label: {
                Label(item.labelText, systemImage: item.labelSystemImage)
            }
        }
    }
}

extension MenuSidebar {
    struct MenuCellContent: View {
        let menu: SidebarMenuValue
        let addSpacer: Bool
        
        init(_ menu: SidebarMenuValue, addSpacer: Bool = true) {
            self.menu = menu
            self.addSpacer = addSpacer
        }
        
        var body: some View {
            HStack(spacing: 0) {
                if let icon = menu.icon {
                    if let color = icon.color {
                        Image(systemName: icon.name)
                            .foregroundStyle(color)
                    } else {
                        Image(systemName: icon.name)
                    }
                    
                    Text(" " + menu.text)
                } else {
                    Text(menu.text)
                }
                
                if addSpacer {
                    Spacer()
                }
            }
        }
    }
}

extension MenuSidebar {
    public struct SidebarMenuValue: Identifiable, Equatable {
        public struct IconConfig: Equatable {
            let name: String
            let color: Color?
            
            public init(name: String, color: Color? = nil) {
                self.name = name
                self.color = color
            }
        }
        
        public enum Mode: Equatable {
            case readonly // 只展示
            case selectable // 可以被选择
            case editable // 可以编辑、删除
        }
        
        public let id: String
        public let text: String
        public let mode: Mode
        public let icon: IconConfig?
        
        public init(
            id: String,
            text: String,
            mode: Mode,
            icon: IconConfig? = nil
        ) {
            self.id = id
            self.text = text
            self.mode = mode
            self.icon = icon
        }
    }
    
    public struct BottomMenuValue: Identifiable, Equatable {
        public enum MenuType {
            case leading
            case trailing
        }
        
        public let id: String
        public let labelText: String
        public let labelSystemImage: String
        public let type: MenuType
        
        init(
            id: String,
            labelText: String,
            labelSystemImage: String,
            type: MenuType
        ) {
            self.id = id
            self.labelText = labelText
            self.labelSystemImage = labelSystemImage
            self.type = type
        }
    }
    
    public struct MenuValues: Equatable {
        public var sidebarMenus: IdentifiedArrayOf<TreeMenuValue> = []
        public var bottomAddMenus: [BottomMenuValue] = []
        public var bottomMoreMenus: [BottomMenuValue] = []
        
        public init(
            sidebarMenus: IdentifiedArrayOf<TreeMenuValue> = [],
            bottomMenus: [BottomMenuValue] = []
        ) {
            self.sidebarMenus = sidebarMenus
            
            var bottomAddMenus: [BottomMenuValue] = []
            var bottomMoreMenus: [BottomMenuValue] = []
            for menu in bottomMenus {
                if menu.type == .leading {
                    bottomAddMenus.append(menu)
                } else {
                    bottomMoreMenus.append(menu)
                }
            }
            self.bottomAddMenus = bottomAddMenus
            self.bottomMoreMenus = bottomMoreMenus
        }
    }
    
    public typealias TreeMenuValue = CommonTreeNode<SidebarMenuValue>
}

#Preview {
    struct Playground: View {
        @State private var selection: MenuSidebar.SidebarMenuValue? = nil
        
        var body: some View {
            ZStack(alignment: .leading) {
                MenuSidebar(
                    bgColor: .blue,
                    activeFontColor: .black,
                    fontColor: .white,
                    deleteButtonColor: .red,
                    editButtonColor: .green,
                    menus: .init(
                        sidebarMenus: .init(uniqueElements: [
                            .init(value: .init(
                                id: UUID().uuidString,
                                text: "menu1",
                                mode: .selectable
                            )),
                            .init(value: .init(
                                id: UUID().uuidString,
                                text: "menu2",
                                mode: .selectable
                            )),
                            .init(value: .init(
                                id: UUID().uuidString,
                                text: "menu3",
                                mode: .selectable
                            ), children: .init(uniqueElements: [
                                .init(value: .init(
                                    id: UUID().uuidString,
                                    text: "menu3-1",
                                    mode: .selectable
                                )),
                                .init(value: .init(
                                    id: UUID().uuidString,
                                    text: "menu3-2",
                                    mode: .selectable
                                )),
                            ]))
                        ]),
                        bottomMenus: [
                            .init(
                                id: UUID().uuidString,
                                labelText: "add1",
                                labelSystemImage: "add",
                                type: .leading
                            ),
                            .init(
                                id: UUID().uuidString,
                                labelText: "add2",
                                labelSystemImage: "add",
                                type: .trailing
                            )
                        ]
                    ),
                    selection: $selection, 
                    onSidebarMenuEdit: { id in
                        print("onSidebarMenuEdit: \(id)")
                    },
                    onSidebarMenuDelete: { id in
                        print("onSidebarMenuDelete: \(id)")
                    },
                    onBottomMenuTapped: { id in
                        print("onBottomMenuTapped: \(id)")
                    }
                ).frame(width: 200)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Content")
                        Spacer()
                    }
                    Spacer()
                }
                .background(Rectangle().fill(Color.gray))
                .frame(width: .infinity, height: .infinity)
                .offset(x: 200)
            }
            
        }
    }
    
    return Playground()
}
