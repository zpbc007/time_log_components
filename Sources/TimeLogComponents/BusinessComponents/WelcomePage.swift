//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2025/1/16.
//

import SwiftUI

public struct WelcomePage: View {
    let pageConfigs: [Self.Config]
    let startAction: () -> Void
    @State private var page = 0
    
    public init(
        configs: [Self.Config],
        startAction: @escaping () -> Void
    ) {
        self.pageConfigs = configs
        self.startAction = startAction
    }
    
    private var maxPage: Int {
        pageConfigs.count - 1
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                InfiniteTab(
                    width: geometry.size.width,
                    minPage: 0,
                    maxPage: maxPage,
                    page: $page
                ) { page in
                    if page < 0 || page > maxPage {
                        EmptyView()
                    } else {
                        self.buildPage(index: page)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    self.IndicatorView
                }.padding(.vertical)
            }
        }
        .safeAreaPadding(.top, 40)
    }
    
    @ViewBuilder
    private func buildPage(index: Int) -> some View {
        VStack {
            Spacer()
            
            Image(pageConfigs[index].img)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(.rect(cornerRadius: 10))
                .padding()
                        
            Text(pageConfigs[index].title)
                .font(.title2)
                .bold()
                .padding(.bottom)
            ForEach(pageConfigs[index].desc, id: \.self) { text in
                Text(text).font(.body)
            }
            
            if index == maxPage {
                Button(action: startAction) {
                    Text("开始使用")
                        .bold()
                        .padding()
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 10)
                        ).padding(.top, 30)
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var IndicatorView: some View {
        HStack {
            ForEach(0..<maxPage + 1, id: \.self) { index in
                Circle()
                    .fill(index == page ? .green : .gray)
                    .frame(width: 10, height: 10)
            }.animation(.easeInOut, value: page)
        }
    }
}

extension WelcomePage {
    public struct Config: Equatable {
        let title: String
        let desc: [String]
        let img: String
        
        public init(title: String, desc: [String], img: String) {
            self.title = title
            self.desc = desc
            self.img = img
        }
    }
}

#Preview {
    WelcomePage(configs: [
        .init(
            title: "时间的迷宫",
            desc: [
                "工作时会因生活琐事分心",
                "休息时又常被工作任务打扰",
                "自由时光也难以真正放松",
                "时间就这样在混乱中悄然流逝"
            ],
            img: ""
        ),
        .init(
            title: "时间的三重奏",
            desc: [
                "生存时刻，细心打理生活，满是踏实",
                "工作时段，专注投入，收获成就感",
                "自由时光，享受自我，尽享惬意"
            ],
            img: ""
        ),
        .init(
            title: "开启时光之旅",
            desc: [
                "在这里",
                "生存、工作、自由时间将被清晰划分",
                "让你的生活更加美好"
            ],
            img: ""
        )
    ]) {
        print("start")
    }.ignoresSafeArea()
}
