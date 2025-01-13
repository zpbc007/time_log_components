//
//  EventCard.swift
//
//
//  Created by zhaopeng on 2025/1/10.
//

import SwiftUI

public struct EventCard: View {
    let title: String
    let tagSFName: String
    let tagName: String
    let tagColor: Color
    
    public init(title: String, tagSFName: String, tagName: String, tagColor: Color) {
        self.title = title
        self.tagSFName = tagSFName
        self.tagName = tagName
        self.tagColor = tagColor
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .padding(.horizontal)
                .padding(.top)
            
            HStack {
                Spacer()
                
                HStack {
                    Image(systemName: tagSFName)
                    Text(tagName)
                }
                .font(.callout)
                .padding(6)
                .background(tagColor, in: RoundedRectangle(cornerRadius: 10))
                
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(.gray, lineWidth: 1)
                .shadow(color: .gray, radius: 2, x: 3, y: 3)
        )
        
    }
}

#Preview {
    VStack(spacing: 25) {
        EventCard(
            title: "费曼学习法",
            tagSFName: "steeringwheel.circle",
            tagName: "自由",
            tagColor: .green.opacity(0.3)
        )
        EventCard(
            title: "费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法",
            tagSFName: "flame.circle",
            tagName: "生存",
            tagColor: .red.opacity(0.3)
        )
        EventCard(
            title: "费曼学习法费曼学习法",
            tagSFName: "building.2.crop.circle",
            tagName: "工作",
            tagColor: .blue.opacity(0.3)
        )
    }.padding()
}
