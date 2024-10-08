//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/19.
//

import SwiftUI

public struct FeedbackView: View {
    let user: UserInfo?
    @State private var request: URLRequest?
    
    public init(user: UserInfo?) {
        self.user = user
    }
    
    public var body: some View {
        Group {
            if let request {
                WebView.Loading(request: request) { reqUrl in
                    guard reqUrl.hasPrefix("weixin://") else {
                        return .allow
                    }
        
                    let targetReqUrl = URL(string: reqUrl)!
                    let canOpenWeixin = UIApplication.shared.canOpenURL(targetReqUrl)
        
                    // 拉起微信
                    if canOpenWeixin {
                        await UIApplication.shared.open(targetReqUrl)
                    }
        
                    return .cancel
                }
            } else {
                ProgressView()
            }
        }
        .task {
            request = buildRequest(user: user)
        }
    }
    
    private func buildRequest(user: UserInfo?) -> URLRequest {
        let clientInfo: String = "\(AppInfo.region) / \(AppInfo.platformName)"
        let clientVersion: String = AppInfo.bundleVersion
        let os: String = AppInfo.systemName
        let osVersion: String = AppInfo.systemVersion
        let bodyString = "openid=\(user?.uid ?? "123")&nickname=\(user?.displayName ?? "")&avatar=\(user?.photoUrl ?? "")&clientInfo=\(clientInfo)&clientVersion=\(clientVersion)&os=\(os)&osVersion=\(osVersion)"
        
        var req = URLRequest(
            url: URL(string: "https://support.qq.com/product/637892")!
        )
        req.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        req.httpMethod = "POST"
        req.httpBody = bodyString.data(using: .utf8)
        
        return req
    }
}

extension FeedbackView {
    // Bundle.main.infoDictionary keys
    // CFBundleShortVersionString  1.0
    // CFBundleIdentifier cool.callback.time-log
    // DTPlatformName iphonesimulator
    // CFBundleVersion 1
    // DTSDKName iphonesimulator17.2
    // CFBundleDevelopmentRegion zh-Hans
    private struct AppInfo {
        private static let DeviceInfo = UIDevice.current
        private static let BundleInfo = Bundle.main.infoDictionary! as Dictionary<String, AnyObject>
        
        // iOS
        static var systemName: String {
            DeviceInfo.systemName
        }
        
        // 17.2
        static var systemVersion: String {
            DeviceInfo.systemVersion
        }
        
        // 1.0
        static var bundleVersion: String {
            BundleInfo["CFBundleShortVersionString"] as! String
        }
        
        // zh-Hans
        static var region: String {
            BundleInfo["CFBundleDevelopmentRegion"] as! String
        }
        
        // iphonesimulator
        static var platformName: String {
            BundleInfo["DTPlatformName"] as! String
        }
    }
}

extension FeedbackView {
    public struct UserInfo {
        let uid: String
        let displayName: String?
        let photoUrl: String?
        
        public init(uid: String, displayName: String?, photoUrl: String?) {
            self.uid = uid
            self.displayName = displayName
            self.photoUrl = photoUrl
        }
    }
}

#Preview("登录用户") {
    NavigationStack {
        FeedbackView(
            user: .init(uid: UUID().uuidString, displayName: "xxx", photoUrl: "https%3A%2F%2Ftxc.qq.com%2Fstatic%2Fdesktop%2Fimg%2Fproducts%2Fdef-product-logo.png")
        )
    }
}

#Preview("未登录用户") {
    NavigationStack {
        FeedbackView(
            user: nil
        )
    }
}
