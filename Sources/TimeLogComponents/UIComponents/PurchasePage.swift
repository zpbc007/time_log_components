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
    let restoreAction: () -> Void
    
    public init(
        features: [FeatureConf],
        monthlyConf: ButtonConf,
        yearlyConf: ButtonConf,
        monthlyAction: @escaping () -> Void,
        yearlyAction: @escaping () -> Void,
        restoreAction: @escaping () -> Void
    ) {
        self.features = features
        self.monthlyConf = monthlyConf
        self.yearlyConf = yearlyConf
        self.monthlyAction = monthlyAction
        self.yearlyAction = yearlyAction
        self.restoreAction = restoreAction
    }
    
    public var body: some View {
        VStack {
            List {
                HStack {
                    Text("会员专属功能")
                        .font(.title2)
                    
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
                        
            HStack {
                Text("购买说明")
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("1. 如果购买未生效，请")
                    Button("恢复购买", action: restoreAction)
                    Spacer()
                }
                
                Text("2. 购买会员后不支持退款")
                
                HStack {
                    Text("3. 如果有其他问题请")
                    
                    NavigationLink {
                        FeedbackView(user: nil)
                            .toolbar(.hidden, for: .tabBar)
                    } label: {
                        Text("联系我们")
                    }
                }
            }
            .font(.footnote)
            .padding(.bottom)
            
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
        let price: Decimal
        let fontColor: Color
        let bgColor: Color
        
        public init(
            price: Decimal,
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
    NavigationStack {
        PurchasePage(
            features: [
                .init(text: "iCloud 同步", desc: "在多设备间同步数据"),
                .init(text: "清单解锁", desc: "无限创建清单"),
                .init(text: "标签", desc: "无限创建标签"),
                .init(text: "更多功能", desc: "努力开发中，敬请期待")
            ],
            monthlyConf: .init(price: 6.2, fontColor: .green, bgColor: .clear),
            yearlyConf: .init(price: 38.9, fontColor: .white, bgColor: .green),
            monthlyAction: {
                print("monthlyAction")
            },
            yearlyAction: {
                print("yearlyAction")
            },
            restoreAction: {
                print("restoreAction")
            }
        )
    }
}
