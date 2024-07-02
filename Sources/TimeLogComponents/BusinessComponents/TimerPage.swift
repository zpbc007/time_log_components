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
    
    @Binding var status: Status
    @State private var elapsedTime = 0.0
    @State private var timer: Timer? = nil
    @State private var showCanNotStartMsg = false
    
    let taskName: String?
    let fontColor: Color
    let buttonBgColor: Color
    let alertColor: Color
    let onTaskNameTapped: () -> Void
    
    public init(
        status: Binding<Status>,
        fontColor: Color,
        buttonBgColor: Color,
        alertColor: Color,
        taskName: String?,
        onTaskNameTapped: @escaping () -> Void
    ) {
        self._status = status
        self.fontColor = fontColor
        self.buttonBgColor = buttonBgColor
        self.alertColor = alertColor
        self.taskName = taskName
        self.onTaskNameTapped = onTaskNameTapped
    }
    
    public var body: some View {
        VStack {
            HStack {
                Text(taskName ?? "选择任务")
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .padding(.bottom)
            .onTapGesture(perform: onTaskNameTapped)
            
            ZStack {
                Circle()
                    .stroke(buttonBgColor, style: .init(lineWidth: 5))
                    .frame(width: 260)
                
                VStack {
                    TimerText(seconds: elapsedTime)
                }.font(.largeTitle)
            }
            
            HStack {
                if status.startDate != nil {
                    Button(
                        action: stopTimer,
                        label: {
                            Image(systemName: "stop.circle.fill")
                                .font(.largeTitle)
                        }
                    )
                } else {
                    Button(
                        action: startTimer,
                        label: {
                            Text("开始")
                                .foregroundStyle(fontColor)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                        }
                    )
                    .background(
                        buttonBgColor,
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                }
            }
            .padding()
        }
        .toast(isPresenting: $showCanNotStartMsg) {
            AlertToast(
                type: .error(alertColor),
                title: "请先选择任务"
            )
        }
    }
    
    private func startTimer() {
        guard let taskName, !taskName.isEmpty else {
            showCanNotStartMsg = true
            return
        }
        
        status = .counting(.now)
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true,
            block: { _ in
                elapsedTime += 1
            }
        )
    }
    
    private func stopTimer() {
        status = .idle
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
}

#Preview {
    struct TimerPagePlayground: View {
        @State private var status: TimerPage.Status = .idle
        
        var body: some View {
            TimerPage(
                status: $status,
                fontColor: .white,
                buttonBgColor: .blue,
                alertColor: .red,
                taskName: "task1-1"
            ) {
                
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

#Preview("empty task name") {
    TimerPage(
        status: .constant(.idle),
        fontColor: .white,
        buttonBgColor: .blue,
        alertColor: .red,
        taskName: nil
    ) {
        
    }
}
