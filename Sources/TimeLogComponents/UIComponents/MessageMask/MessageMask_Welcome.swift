//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/5/28.
//

import SwiftUI

extension MessageMask {
    struct WelcomeView: View {
        var body: some View {
            VStack {
                Text("你的时间和金钱流向哪儿")
                    .padding(.bottom)
                Text("你的人生就走向哪儿")
            }
            .font(.title)
        }
    }
}

#Preview {
    MessageMask<EmptyView>.WelcomeView()
}
