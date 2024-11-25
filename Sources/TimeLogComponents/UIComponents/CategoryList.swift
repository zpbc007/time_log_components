//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/11/17.
//

import SwiftUI

public struct CategoryList: View {
    let categories: [Item]
    let tapAction: (Item) -> Void
    let editAction: Optional<(Item) -> Void>
    
    public init(
        categories: [Item],
        tapAction: @escaping (Item) -> Void,
        editAction: Optional<(Item) -> Void>
    ) {
        self.categories = categories
        self.tapAction = tapAction
        self.editAction = editAction
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 130))
            ], spacing: 20) {
                ForEach(categories) { item in
                    VStack(spacing: 5) {
                        self.buildHeader(item)
                        
                        self.buildText(item)
                        
                        Spacer()
                        
                        self.buildFooter(item)
                    }
                    .frame(width: 140, height: 135)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .onTapGesture(perform: {
                        tapAction(item)
                    })
                }
            }
        }.padding(.horizontal)
    }
    
    @ViewBuilder
    private func buildHeader(_ item: Item) -> some View {
        if let editAction {
            HStack {
                Spacer()
                
                Image(systemName: "square.and.pencil")
                    .onTapGesture(perform: {
                        editAction(item)
                    })
                    .padding(.vertical)
                    .clipShape(.rect)
            }
        } else {
            Spacer()
        }
    }
    
    @ViewBuilder
    private func buildText(_ item: Item) -> some View {
        Text(item.name)
            .lineLimit(2)
            .font(.title3)
            .bold()
    }
    
    @ViewBuilder
    private func buildFooter(_ item: Item) -> some View {
        HStack {
            HStack {}
                .frame(width: 15, height: 15)
                .background(item.color, in: Circle())
            
            Spacer()
            
            Text("\(item.count)")
                .font(.callout)
        }.padding(.bottom)
    }
}

extension CategoryList {
    public struct Item: Equatable, Identifiable {
        public let id: String
        public let name: String
        public let color: Color
        public let count: Int
        
        public init(
            id: String,
            name: String,
            color: Color,
            count: Int
        ) {
            self.id = id
            self.name = name
            self.color = color
            self.count = count
        }
    }
}

#Preview {
    struct Playground: View {
        let categories: [CategoryList.Item] = [
            .init(id: UUID().uuidString, name: "学习投入投入", color: .red, count: 5),
            .init(id: UUID().uuidString, name: "兴趣投入", color: .green, count: 3),
            .init(id: UUID().uuidString, name: "语言学习", color: .blue, count: 5),
            .init(id: UUID().uuidString, name: "工作投入", color: .cyan, count: 5),
            .init(id: UUID().uuidString, name: "健康投入超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长超长", color: .red, count: 5),
            .init(id: UUID().uuidString, name: "运动投入", color: .green, count: 5),
            .init(id: UUID().uuidString, name: "感情投入", color: .brown, count: 5),
            .init(id: UUID().uuidString, name: "感情投入", color: .black, count: 5)
        ]
        @State private var canEdit = false
        
        private var editAction: Optional<(CategoryList.Item) -> Void> {
            guard canEdit else {
                return nil
            }
            
            return { item in
                print("edit \(item.name)")
            }
        }
        
        var body: some View {
            NavigationStack {
                VStack {
                    Button("canEdit: \(canEdit ? "yes" : "no")") {
                        canEdit.toggle()
                    }
                    
                    CategoryList(
                        categories: categories,
                        tapAction: { item in
                            print("tap: \(item.name)")
                        },
                        editAction: editAction
                    )
                }
            }
        }
    }
   
    return Playground()
}
