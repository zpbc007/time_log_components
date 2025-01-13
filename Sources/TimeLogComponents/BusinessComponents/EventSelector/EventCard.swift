//
//  EventCard.swift
//
//
//  Created by zhaopeng on 2025/1/10.
//

import SwiftUI

public struct EventCard: View {
    let title: String
    let active: Bool
    let lifetimeTagConf: LifetimeTagConf?
    
    public init(
        title: String,
        active: Bool,
        lifetimeTagConf: LifetimeTagConf? = nil
    ) {
        self.title = title
        self.active = active
        self.lifetimeTagConf = lifetimeTagConf
    }
    
    public var body: some View {
        Group {
            if let lifetimeTagConf {
                buildWithTagView(conf: lifetimeTagConf)
            } else {
                withoutTagView
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(active == true ? .blue : .gray, lineWidth: 1)
                .shadow(color: active == true ? .blue : .gray, radius: 2, x: 3, y: 3)
                .animation(.easeInOut, value: active)
        )
    }
    
    @ViewBuilder
    var withoutTagView: some View {
        VStack {
            Text(title)
                .padding()
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    func buildWithTagView(conf: LifetimeTagConf) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .padding(.horizontal)
                .padding(.top)
            
            HStack {
                Spacer()
                
                HStack {
                    Image(systemName: conf.sfName)
                    Text(conf.name)
                }
                .font(.callout)
                .padding(6)
                .background(
                    conf.color,
                    in: RoundedRectangle(cornerRadius: 10)
                )
                
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

extension EventCard {
    public struct LifetimeTagConf: Equatable {
        public let name: String
        public let sfName: String
        public let color: Color
    
        public init(name: String, sfName: String, color: Color) {
            self.name = name
            self.sfName = sfName
            self.color = color
        }
    }
}

#Preview {
    VStack(spacing: 25) {
        EventCard(title: "费曼学习法", active: false)
        EventCard(
            title: "费曼学习法",
            active: true,
            lifetimeTagConf: .init(
                name: "自由",
                sfName: "steeringwheel.circle",
                color: .green.opacity(0.3)
            )
        )
        EventCard(
            title: "费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法费曼学习法",
            active: false,
            lifetimeTagConf: .init(
                name: "生存",
                sfName: "flame.circle",
                color: .red.opacity(0.3)
            )
        )
        EventCard(
            title: "费曼学习法费曼学习法",
            active: false,
            lifetimeTagConf: .init(
                name: "工作",
                sfName: "building.2.crop.circle",
                color: .blue.opacity(0.3)
            )
        )
    }.padding()
}
