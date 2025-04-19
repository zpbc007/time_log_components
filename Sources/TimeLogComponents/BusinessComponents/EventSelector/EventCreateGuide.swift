//
//  EventCreateGuide.swift
//  time-log-components
//
//  Created by zhaopeng on 2025/4/17.
//

import SwiftUI
import SVGView

public struct EventCreateGuide: View {
    let addEventAction: () -> Void
    let pickEventAction: () -> Void
    
    public init(
        addEventAction: @escaping () -> Void,
        pickEventAction: @escaping () -> Void
    ) {
        self.addEventAction = addEventAction
        self.pickEventAction = pickEventAction
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            Text("当前还没有可以用于记录的事件")
            
            HStack {
                Text("可以")
                Button(action: addEventAction) {
                    Label("创建自定义事件", systemImage: "plus")
                        .font(.title2)
                        .bold()
                }
            }
            
            HStack {
                Text("或者")
                Button(action: pickEventAction) {
                    Label("从事件库中挑选", systemImage: "checklist")
                        .font(.title2)
                        .bold()
                }
            }
            
            self.PicView
        }
        .font(.title3)
        .padding()
    }
    
    @ViewBuilder
    private var PicView: some View {
        if let voidUrl = Bundle.module.url(
            forResource: "void",
            withExtension: "svg"
        ) {
            SVGView(contentsOf: voidUrl)
                .aspectRatio(contentMode: .fit)
                .padding()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    EventCreateGuide {
        print("add event")
    } pickEventAction: {
        print("pick event")
    }

}
