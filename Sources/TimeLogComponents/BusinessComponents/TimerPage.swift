//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/17.
//

import SwiftUI
import AlertToast

fileprivate let radius: CGFloat = 130

public enum TimerPageStatus: Equatable {
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

public struct TimerPage<FlagView: View>: View {
    let status: TimerPageStatus
    let editAction: () -> Void
    let stopAction: () -> Void
    let flagView: () -> FlagView
    @State private var elapsedTime = 0.0
    @State private var timer: Timer? = nil
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    let fontColor: Color
    let buttonBgColor: Color
    let taskName: String
    
    public init(
        status: TimerPageStatus,
        fontColor: Color,
        buttonBgColor: Color,
        taskName: String,
        editAction: @escaping () -> Void,
        stopAction: @escaping () -> Void,
        @ViewBuilder
        flagView: @escaping () -> FlagView
    ) {
        self.status = status
        self.fontColor = fontColor
        self.buttonBgColor = buttonBgColor
        self.taskName = taskName
        self.editAction = editAction
        self.stopAction = stopAction
        self.flagView = flagView
    }
    
    public var body: some View {
        Group {
            if verticalSizeClass == .compact {
                self.compactContent
            } else {
                self.regularContent
            }
        }.onChange(of: status, initial: true) { oldValue, newValue in
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
    
    @ViewBuilder
    private var compactContent: some View {
        HStack {
            VStack {
                self.flagView()
                
                self.taskNameView
                    .padding(.vertical)
            }
            
            self.clockView
        }.padding()
    }
    
    @ViewBuilder
    private var regularContent: some View {
        VStack {
            self.flagView()
                        
            self.clockView
                .padding(.vertical)
                        
            self.taskNameView
        }.padding()
    }
    
    @ViewBuilder
    private var clockView: some View {
        ZStack {
            Circle()
                .stroke(buttonBgColor, style: .init(lineWidth: 5))
                .frame(width: radius * 2)
            
            TimerText(seconds: elapsedTime)
                .font(.largeTitle)
            
            HStack {
                Button(
                    action: editAction,
                    label: {
                        Image(systemName: "pencil.circle")
                            .font(.largeTitle)
                    }
                )
                
                Button(
                    action: stopAction,
                    label: {
                        Image(systemName: "stop.circle.fill")
                            .font(.largeTitle)
                    }
                )
            }
            .offset(CGSize(width: 0, height: radius / 2))
        }
    }
    
    @ViewBuilder
    private var taskNameView: some View {
        VStack {
            Text("进行中的任务")
                .font(.caption)
            Text(taskName)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .font(.title2)
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
        @State private var status: TimerPageStatus = .counting(.now)
        
        var body: some View {
            TimerPage(
                status: status,
                fontColor: .white,
                buttonBgColor: .blue,
                taskName: "选中的任务"
            ) {
                self.status = .counting(.now)
            } stopAction: {
                self.status = .idle
            } flagView: {
                Image(systemName: "clock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
            }
            .onChange(of: status) { oldValue, newValue in
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
        @State private var status: TimerPageStatus = .counting(.now.addingTimeInterval(-60))
        
        var body: some View {
            TimerPage(
                status: status,
                fontColor: .white,
                buttonBgColor: .blue,
                taskName: "选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务选中的任务"
            ) {
                self.status = .counting(.now)
            } stopAction: {
                self.status = .idle
            } flagView: {
                Image(systemName: "clock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
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
