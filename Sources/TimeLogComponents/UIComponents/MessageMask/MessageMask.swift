//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/5/28.
//

import SwiftUI

public class MessageMaskDataProvider: ObservableObject {
    public struct ErrorInfo {
        public let title: String
        public let msg: String
        
        public init(title: String, msg: String) {
            self.title = title
            self.msg = msg
        }
    }
    public enum Status {
        case showWelcome
        case dismiss
        case error(ErrorInfo)
        
        var showWelcome: Bool {
            switch self {
            case .showWelcome:
                return true
            default:
                return false
            }
        }
        
        var errorInfo: ErrorInfo? {
            switch self {
            case .error(let errorInfo):
                return errorInfo
            default:
                return nil
            }
        }
    }
    
    // 展示实际内容
    @Published public var status: Status = .showWelcome
    
    // 完成前期准备后调用
    public func finishPrepare() {
        status = .dismiss
    }
    
    // 出错后调用
    public func onError(error: ErrorInfo) {
        status = .error(error)
    }
}

public struct MessageMask<Content: View>: View {
    let bgColor: Color
    let retryButtonFontColor: Color
    let retryButtonBGColor: Color
    let retryAction: () -> Void
    let content: () -> Content
    
    @StateObject private var dataProvider = MessageMaskDataProvider()
    
    public init(
        bgColor: Color,
        retryButtonFontColor: Color,
        retryButtonBGColor: Color,
        retryAction: @escaping () -> Void,
        content: @escaping () -> Content
    ) {
        self.bgColor = bgColor
        self.retryButtonFontColor = retryButtonFontColor
        self.retryButtonBGColor = retryButtonBGColor
        self.retryAction = retryAction
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            content()
                .environmentObject(dataProvider)
            
            if dataProvider.status.showWelcome {
                WelcomeView()
                    .zIndex(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(bgColor)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .scale
                    ))
                
                ProgressView()
                    .controlSize(.extraLarge)
                    .zIndex(3)
            }
                        
            if let errorInfo = dataProvider.status.errorInfo {
                ErrorMessageView(
                    info: errorInfo,
                    buttonFontColor: retryButtonFontColor,
                    buttonBGColor: retryButtonBGColor,
                    retryAction: retryAction
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(bgColor)
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .scale
                ))
            }
        }
        .ignoresSafeArea()
    }
}

#Preview("success") {
    struct RealContent: View {
        @EnvironmentObject private var dataProvider: MessageMaskDataProvider
        
        var body: some View {
            Text("real content")
                .task {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        dataProvider.finishPrepare()
                    }
                }
        }
    }
    
    struct PlaygroundView: View {
        var body: some View {
            MessageMask(
                bgColor: .white,
                retryButtonFontColor: .white,
                retryButtonBGColor: .black
            ) {
                print("retry")
            } content: {
                RealContent()
            }
        }
    }
    
    return PlaygroundView()
}

#Preview("error") {
    struct RealContent: View {
        @EnvironmentObject private var dataProvider: MessageMaskDataProvider
        
        var body: some View {
            Text("real content")
                .task {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        dataProvider.onError(error: .init(title: "获取数据出错", msg: "稍后再试"))
                    }
                }
        }
    }
    
    struct PlaygroundView: View {
        var body: some View {
            MessageMask(
                bgColor: .white,
                retryButtonFontColor: .white,
                retryButtonBGColor: .black
            ) {
                print("retry")
            } content: {
                RealContent()
            }
        }
    }
    
    return PlaygroundView()
}
