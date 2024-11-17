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
    
    public init(
        categories: [Item],
        tapAction: @escaping (Item) -> Void
    ) {
        self.categories = categories
        self.tapAction = tapAction
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 130))
            ], spacing: 20) {
                ForEach(categories) { item in
                    VStack(spacing: 5) {
                        Spacer()
                        
                        Text(item.name)
                            .lineLimit(2)
                            .font(.title3)
                            .bold()
                            .padding(.top)
                        
                        Spacer()
                        
                        HStack {
                            HStack {}
                                .frame(width: 15, height: 15)
                                .background(item.color, in: Circle())
                            
                            Spacer()
                            
                            Text("\(item.count)")
                                .font(.callout)
                        }.padding(.bottom)
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
        
        var body: some View {
            NavigationStack {
                CategoryList(categories: categories) { item in
                    print("tap: \(item.name)")
                }
            }
        }
    }
   
    return Playground()
}
