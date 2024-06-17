//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/17.
//

import SwiftUI

struct TimerText: View {
    static let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter
    }()
    
    let seconds: Double
    
    var body: some View {
        Text("\(Self.formatter.string(from: seconds) ?? "")")
    }
}

#Preview {
    struct Playground: View {
        @State private var seconds: Double = 0
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
        var body: some View {
            TimerText(seconds: seconds)
                .onReceive(timer, perform: { _ in
                    seconds += 1
                })
        }
    }
    
    return Playground()
}
