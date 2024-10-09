//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/19.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let request: URLRequest
    let navigationActionPolicyResolver: (String) async -> WKNavigationActionPolicy
    @Binding var level: Int
    @Binding var isLoading: Bool
    @Binding var error: Error?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        let wkwebView = WKWebView()
        wkwebView.uiDelegate = context.coordinator
        wkwebView.navigationDelegate = context.coordinator
        wkwebView.isOpaque = false
        wkwebView.backgroundColor = .clear
        wkwebView.load(request)
        return wkwebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let backListGetter = {
            uiView.backForwardList.backList
        }
        let forwardListGetter = {
            uiView.backForwardList.forwardList
        }
        
        if backListGetter().count > level {
            let needBack = backListGetter().count - level
            // 如果当前后退列表的数量大于绑定的 level，则后退到指定的级别
            for _ in 0..<needBack {
                uiView.goBack()
                // 到头了
                if backListGetter().isEmpty {
                    break
                }
            }
        } else if backListGetter().count < level {
            let needForward = level - backListGetter().count
            // 如果当前后退列表的数量小于绑定的 level，则尝试前进到指定的级别
            for _ in 0..<needForward {
                uiView.goForward()
                // 到头了
                if forwardListGetter().isEmpty {
                    break
                }
            }
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(
            _ webView: WKWebView,
            didCommit navigation: WKNavigation!
        ) {
            parent.level += 1
            parent.isLoading = true
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            parent.isLoading = false
            updateParentLevel(webView)
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.isLoading = false
            parent.error = error
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction
        ) async -> WKNavigationActionPolicy {
            guard let reqUrl = navigationAction.request.url?.absoluteString else {
                return .allow
            }
            
            return await parent.navigationActionPolicyResolver(reqUrl)
        }
        
        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.isLoading = false
            parent.error = error
        }

        func webView(
            _ webView: WKWebView,
            didGoBack navigation: WKNavigation!
        ) {
            // 网页后退，更新当前级别
            updateParentLevel(webView)
        }

        func webView(
            _ webView: WKWebView,
            didGoForward navigation: WKNavigation!
        ) {
            // 网页前进，更新当前级别
            updateParentLevel(webView)
        }
        
        private func updateParentLevel(_ webView: WKWebView) {
            parent.level = webView.backForwardList.backList.count + 1
        }
    }
}

extension WebView {
    struct Loading: View {
        @State private var level: Int = 0
        @State private var isLoading = true
        @State private var error: Error? = nil
        
        let request: URLRequest
        let navigationActionPolicyResolver: (String) async -> WKNavigationActionPolicy
        
        var body: some View {
            ZStack {
                if let error = error {
                    Text(error.localizedDescription)
                        .foregroundColor(.pink)
                } else {
                    WebView(
                        request: request,
                        navigationActionPolicyResolver: navigationActionPolicyResolver,
                        level: $level,
                        isLoading: $isLoading,
                        error: $error
                    ).dismissBtn {
                        
                    }.toolbar {
                        Button("level: \(level)") {
                            level -= 1
                        }
                    }

                    if isLoading {
                        ProgressView()
                    }
                }
            }
        }
    }
}

#Preview {
    struct WebViewPlayground: View {
        @State private var level = 0
        @State private var isLoading = true
        @State private var error: Error? = nil
        let request: URLRequest = {
            var req = URLRequest(
                url: URL(string: "https://support.qq.com/product/637892")!
            )
            req.setValue(
                "application/x-www-form-urlencoded",
                forHTTPHeaderField: "Content-Type"
            )
            req.httpMethod = "POST"
            
            return req
        }()
                
        var body: some View {
            NavigationStack {
                WebView.Loading(request: request) { _ in
                    .allow
                }
            }
        }
    }
    
    return WebViewPlayground()
}
