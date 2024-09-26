//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/17.
//

import SwiftUI
import AlertToast

public struct TimerPage: View {
    public enum Status: Equatable {
        case idle
        // 计时中
        case counting(_ startDate: Date)
        
        public var startDate: Date? {
            switch self {
            case .counting(let startDate):
                return startDate
            default:
                return nil
            }
        }
        
        public var inCounting: Bool {
            switch self {
            case .counting:
                return true
            default:
                return false
            }
        }
    }
    static let radius: CGFloat = 130
    
    let status: Status
    let onStop: () -> Void
    @State private var elapsedTime = 0.0
    @State private var timer: Timer? = nil
    @Environment(\.scenePhase) private var scenePhase
    
    let fontColor: Color
    let buttonBgColor: Color
    let taskName: String
    
    public init(
        status: Status,
        fontColor: Color,
        buttonBgColor: Color,
        taskName: String,
        onStop: @escaping () -> Void
    ) {
        self.status = status
        self.fontColor = fontColor
        self.buttonBgColor = buttonBgColor
        self.taskName = taskName
        self.onStop = onStop
    }
    
    public var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(buttonBgColor, style: .init(lineWidth: 5))
                    .frame(width: Self.radius * 2)
                
                TimerText(seconds: elapsedTime)
                    .font(.largeTitle)
                
                Button(
                    action: onStop,
                    label: {
                        Image(systemName: "stop.circle.fill")
                            .font(.largeTitle)
                    }
                ).offset(CGSize(width: 0, height: Self.radius / 2))
            }
            
            VStack {
                Text("进行中的任务")
                    .font(.caption)
                Text(taskName)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .font(.title2)
            }
            .padding()
        }
        .onChange(of: status, initial: true) { oldValue, newValue in
            // reset
            timer?.invalidate()
            timer = nil
            elapsedTime = 0
            
            if status.inCounting {
                self.tryRecoveryElapsedTime()
                timer = Timer.scheduledTimer(
                    withTimeInterval: 1.0,
                    repeats: true,
                    block: { _ in
                        elapsedTime += 1
                    }
                )
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                tryRecoveryElapsedTime()
            }
        }
    }
    
    private func tryRecoveryElapsedTime() {
        if let startDate = status.startDate {
            elapsedTime = Date.now.timeIntervalSince(startDate)
        }
    }
}

#Preview {
    struct TimerPagePlayground: View {
        @State private var status: TimerPage.Status = .counting(.now)
        
        var body: some View {
            TimerPage(
                status: status,
                fontColor: .white,
                buttonBgColor: .blue,
                taskName: "选中的任务"
            ) {
                self.status = .idle
            }.onChange(of: status) { oldValue, newValue in
                if let startDate = oldValue.startDate, newValue == .idle {
                    print("finish record, startDate: \(startDate)")
                }
                
                if newValue.inCounting {
                    print("start record")
                }
            }
        }
    }
        
    return TimerPagePlayground()
}

#Preview("restore state") {
    struct TimerPagePlayground: View {
        @State private var status: TimerPage.Status = .counting(.now.addingTimeInterval(-60))
        
        var body: some View {
            TimerPage(
                status: status,
                fontColor: .white,
                buttonBgColor: .blue,
                taskName: "选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务"
            ) {
                self.status = .idle
            }.onChange(of: status) { oldValue, newValue in
                if let startDate = oldValue.startDate, newValue == .idle {
                    print("finish record, startDate: \(startDate)")
                }
                
                if newValue.inCounting {
                    print("start record")
                }
            }
        }
    }
        
    return TimerPagePlayground()
}
