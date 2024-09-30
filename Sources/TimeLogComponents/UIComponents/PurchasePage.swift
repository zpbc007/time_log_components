//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/9/27.
//

import SwiftUI

public struct PurchasePage: View {
    let features: [FeatureConf]
    let monthlyConf: ButtonConf
    let yearlyConf: ButtonConf
    let monthlyAction: () -> Void
    let yearlyAction: () -> Void
    
    public init(
        features: [FeatureConf],
        monthlyConf: ButtonConf,
        yearlyConf: ButtonConf,
        monthlyAction: @escaping () -> Void,
        yearlyAction: @escaping () -> Void
    ) {
        self.features = features
        self.monthlyConf = monthlyConf
        self.yearlyConf = yearlyConf
        self.monthlyAction = monthlyAction
        self.yearlyAction = yearlyAction
    }
    
    public var body: some View {
        VStack {
            List {
                HStack {
                    Text("会员专属功能")
                        .font(.title)
                    
                    Spacer()
                }.listRowInsets(EdgeInsets())
                
                ForEach(features) { item in
                    HStack {
                        Text(item.text)
                            .bold()
                        Text(item.desc)
                            .fontWeight(.light)
                    }.listRowInsets(EdgeInsets())
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            
            Spacer()
            
            HStack {
                RoundedButton(
                    "连续包月(￥\(monthlyConf.price)/月)",
                    bgColor: monthlyConf.bgColor,
                    borderColor: monthlyConf.fontColor,
                    action: monthlyAction
                ).foregroundStyle(monthlyConf.fontColor)
                
                Spacer()
                
                RoundedButton(
                    "连续包年(￥\(yearlyConf.price)/年)",
                    bgColor: yearlyConf.bgColor,
                    borderColor: yearlyConf.bgColor,
                    action: yearlyAction
                ).foregroundStyle(yearlyConf.fontColor)
            }
        }.padding()
    }
}

extension PurchasePage {
    public struct ButtonConf: Equatable {
        let price: Int
        let fontColor: Color
        let bgColor: Color
        
        public init(
            price: Int,
            fontColor: Color,
            bgColor: Color
        ) {
            self.price = price
            self.fontColor = fontColor
            self.bgColor = bgColor
        }
    }
}

extension PurchasePage {
    public struct FeatureConf: Equatable, Identifiable {
        let text: String
        let desc: String
        
        public var id: String {
            text
        }
        
        public init(text: String, desc: String) {
            self.text = text
            self.desc = desc
        }
    }
}

#Preview {
    PurchasePage(
        features: [
            .init(text: "iCloud 同步", desc: "在多设备间同步数据"),
            .init(text: "清单解锁", desc: "无限创建清单"),
            .init(text: "标签", desc: "无限创建标签"),
            .init(text: "更多功能", desc: "努力开发中，敬请期待")
        ],
        monthlyConf: .init(price: 6, fontColor: .green, bgColor: .white),
        yearlyConf: .init(price: 38, fontColor: .white, bgColor: .green),
        monthlyAction: {},
        yearlyAction: {}
    )
}
