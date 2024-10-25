//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/23.
//

import SwiftUI
import WebKit

public struct RichTextViewer: View {
    let content: String
    @StateObject
    private var viewModel: ViewModel
    
    public init(content: String) {
        self.content = content
        self._viewModel = StateObject(wrappedValue: .init(content))
    }
    
    public var body: some View {
        WebView()
            .onChange(of: content, { oldValue, newValue in
                viewModel.updateContent(newValue)
            })
            .environmentObject(viewModel)
    }
}

extension RichTextViewer {
    typealias ViewModel = RichTextCommon.ViewModel
}

extension RichTextViewer {
    struct WebView: UIViewRepresentable, RichTextWebView {
        @EnvironmentObject var viewModel: RichTextViewer.ViewModel
        
        func makeUIView(context: Context) -> WKWebView {
            let wkConfig = RichTextCommon.makeWKConfig()
            let webView = WKWebView(frame: .zero, configuration: wkConfig)
            
            // webview config
            RichTextCommon.updateWebView(webView, readOnly: true, navDelegate: context.coordinator)
            // bridge
            context.coordinator.bridge.updateWebview(webView)
            
            return webView
        }
        
        func updateUIView(_ webView: WKWebView, context: Context) {
            // 这里需要与 Binding 建立关联关系，不然不会更新
            let _ = viewModel.content
            let _ = viewModel.fetchContentId
            context.coordinator.bridge.updateWebview(webView)
            context.coordinator.syncContent(viewModel.content)
            context.coordinator.fetchContent()
        }
        
        func makeCoordinator() -> RichTextCommon.Coordinator {
            RichTextCommon.Coordinator(self)
        }
        
        func updateWebViewHeight(_ webView: WKWebView, bridge: JSBridge) {
            
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var content: String = "{\"ops\":[{\"insert\":\"init content\",\"attributes\":{\"bold\":true}}]}"
        
        var body: some View {
            VStack {
                RichTextViewer(content: content)
                
                Button("update") {
                    content = "{\"ops\":[{\"insert\":\"new content\",\"attributes\":{\"bold\":true}}]}"
                }
            }.padding()
        }
    }
    
    return Playground()
}
