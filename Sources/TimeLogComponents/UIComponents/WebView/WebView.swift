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
    @Binding var direction: Direction
    @Binding var canGoBack: Bool
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
        guard direction != .idle else {
            return
        }
        
        if direction == .forward && uiView.canGoForward {
            uiView.goForward()
        }
        
        if direction == .back && uiView.canGoBack {
            uiView.goBack()
        }
        context.coordinator.resetDirection()
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
            parent.isLoading = true
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.isLoading = false
//            parent.error = error
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
//            parent.error = error
        }
        
        func resetDirection() {
            parent.direction = .idle
        }
    }
}

extension WebView {
    enum Direction {
        case forward
        case back
        case idle
    }
}

extension WebView {
    struct Loading: View {
        @State private var direction: WebView.Direction = .idle
        @State private var isLoading = true
        @State private var canGoBack = false
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
                        direction: $direction,
                        canGoBack: $canGoBack,
                        isLoading: $isLoading,
                        error: $error
                    ).dismissBtn {
                        
                    }.toolbar {
                        HStack {
                            Button("back \(direction == .back ? "back" : (direction == .idle) ? "idle" : "forward")") {
                                direction = .back
                            }.disabled(!canGoBack)
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
