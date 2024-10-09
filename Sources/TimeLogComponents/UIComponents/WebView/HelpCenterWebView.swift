//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/19.
//

import SwiftUI

public struct HelpCenterWebView: View {
    static let request: URLRequest = URLRequest(
        url: URL(string: "https://iqf6vdn65mw.feishu.cn/docx/UoGmd4spYoEz5lxX0OscQ22anPe?from=from_copylink")!
    )
    
    public init() {}
    
    public var body: some View {
        WebView.Loading(request: Self.request) { reqUrl in
            // 打开飞书
            if reqUrl.contains("lark://") {
                return .allow
            }
            
            if reqUrl.contains("feishu") // 避免打开外部链接
            {
                return .allow
            } else {
                return .cancel
            }
        }
    }
}

#Preview {
    NavigationStack {
        HelpCenterWebView()
    }
}
