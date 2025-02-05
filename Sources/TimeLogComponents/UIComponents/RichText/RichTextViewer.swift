//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/23.
//

import SwiftUI
import WebKit

public struct RichTextViewer: View {
    let title: String?
    let content: String
    let placeholder: String
    
    @StateObject
    private var viewModel: ViewModel
    @State
    private var height: CGFloat = 10
    
    public init(title: String? = nil, content: String, placeholder: String) {
        self.title = title
        self.content = content
        self.placeholder = placeholder
        self._viewModel = StateObject(wrappedValue: .init(content))
    }
        
    public var body: some View {
        VStack {
            if let title, !title.isEmpty {
                Text(title)
                    .bold()
                    .padding(.top)
            }
            
            WebView(placeholder: placeholder, height: $height)
                .frame(height: height)
                .onChange(of: content, { oldValue, newValue in
                    viewModel.updateContent(newValue)
                })
                .environmentObject(viewModel)
        }
    }
}

extension RichTextViewer {
    typealias ViewModel = RichTextCommon.ViewModel
}

extension RichTextViewer {
    struct WebView: UIViewRepresentable, RichTextWebView {
        @EnvironmentObject var viewModel: RichTextViewer.ViewModel
        let placeholder: String
        @Binding var height: CGFloat
        
        func makeUIView(context: Context) -> WKWebView {
            let wkConfig = RichTextCommon.makeWKConfig()
            let webView = WKWebView(frame: .zero, configuration: wkConfig)
            
            // webview config
            RichTextCommon.updateWebView(
                webView,
                editorOptions: .init(readOnly: true, placeholder: placeholder),
                navDelegate: context.coordinator
            )
            // bridge
            context.coordinator.bridge.updateWebview(webView)
            
            return webView
        }
        
        func updateUIView(_ webView: WKWebView, context: Context) {
            // 这里需要与 Binding 建立关联关系，不然不会更新
            let _ = viewModel.content
            let _ = viewModel.fetchContentId
            
            context.coordinator.updateWebview(webView)
            context.coordinator.syncContent(viewModel.content)
            context.coordinator.fetchContent()
        }
        
        func makeCoordinator() -> RichTextCommon.Coordinator {
            RichTextCommon.Coordinator(viewModel: self.viewModel, height: $height)
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var content: String = ""
        
        var body: some View {
            VStack {
                RichTextViewer(
                    title: "title",
                    content: content,
                    placeholder: "Placeholder"
                ).border(.black)
                
                Button("update") {
                    content = "{\"ops\":[{\"insert\":\"new contentnew contentnew contentnew contentnew contentnew contentnew content\",\"attributes\":{\"bold\":true}}]}"
                }
            }.padding()
        }
    }
    
    return Playground()
}
