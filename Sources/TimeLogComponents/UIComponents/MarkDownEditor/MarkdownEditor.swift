//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/9.
//

import SwiftUI
import WebKit

public struct MarkdownEditor: View {
    public init() {}
    
    public var body: some View {
        WebView()
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Click me!") {
                        print("Clicked")
                    }
                }
            }
    }
}

extension MarkdownEditor {
    struct WebView: UIViewRepresentable {
        func makeUIView(context: Context) -> WKWebView {
            let wkConfig = WKWebViewConfiguration()
            let userContentController = WKUserContentController()
            
            // 注入 JS
            self.injectQuillScript(userContentController)
            self.injectCreateEditorScript(userContentController)
            
            wkConfig.userContentController = userContentController
                    
            let webView = WKWebView(frame: .zero, configuration: wkConfig)
            webView.loadHTMLString(self.genInitHTML(), baseURL: nil)
            webView.isInspectable = true
            
            return webView
        }
        
        func updateUIView(_ webView: WKWebView, context: Context) {
        }
        
        private func injectQuillScript(_ userContentController: WKUserContentController) {
            // 加载 js\css 文件
            let quillJsURL = Bundle.module.url(forResource: "quill", withExtension: "js")
            
            guard
                let quillJsURL,
                let quillJSString = try? String(contentsOf: quillJsURL)
            else {
                return
            }
            
            let quillScript = WKUserScript(source: quillJSString, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            userContentController.addUserScript(quillScript)
        }
        
        private func injectCreateEditorScript(_ userContentController: WKUserContentController) {
            let createEditorJSString = """
                const options = {
                    modules: {
                        
                    },
                    theme: 'snow'
                }
                const quill = new Quill('#editor', options);
            """
            let createEditorScript = WKUserScript(source: createEditorJSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(createEditorScript)
        }
        
        private func genInitHTML() -> String {
            // 加载 js\css 文件
            let quillCssURL = Bundle.module.url(forResource: "quill.snow", withExtension: "css")
            
            var finalCssString = ""
            if
                let quillCssURL,
                let quillCssString = try? String(contentsOf: quillCssURL)
            {
                finalCssString = quillCssString.trimmingCharacters(in: .newlines).replacingOccurrences(of: "'", with: "\'")
            }
                    
            return """
            <!DOCTYPE html>
            <html>
            <head><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1, shrink-to-fit=no"></head>
            <style>\(finalCssString)</style>
            <body>
            <div id="info">
            </div>
            <div id="editor">
              <h2>Demo Content</h2>
              <p>Preset build with <code>snow</code> theme, and some common formats.</p>
            </div>
            </body>
            </html>
            """
        }
    }
}

#Preview {
    struct Playground: View {
        var body: some View {
            NavigationStack {
                MarkdownEditor()
                    .padding()
                    .background(.red)
            }
        }
    }
    
    return Playground()
}
