//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/9.
//

import SwiftUI
import WebKit

struct MarkdownEditor: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let wkConfig = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 加载 js\css 文件
        let jsURL = Bundle.module.url(forResource: "quill", withExtension: "js")
        let cssURL = Bundle.module.url(forResource: "quill.snow", withExtension: "css")
        
        guard 
            let jsURL,
            let script = try? String(contentsOf: jsURL),
            let cssURL,
            let cssString = try? String(contentsOf: cssURL)
        else {
            return WKWebView()
        }
        
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    
        let insertCssJSString = """
           var style = document.createElement('style');
           style.innerHTML = '\(cssString.trimmingCharacters(in: .newlines).replacingOccurrences(of: "'", with: "\\'"))';
           document.head.appendChild(style);
        """
        let insertCssScript = WKUserScript(source: insertCssJSString, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        print(insertCssJSString)
        
        let createEditorJSString = """
            const options = {
                modules: {
                    
                },
                theme: 'snow'
            }
            const quill = new Quill('#editor', options);
        """
        let createEditorScript = WKUserScript(source: createEditorJSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        userContentController.addUserScript(insertCssScript)
        userContentController.addUserScript(userScript)
        userContentController.addUserScript(createEditorScript)
        
        wkConfig.userContentController = userContentController
        
        let htmlString = """
         <!DOCTYPE html>
        <html>
        <head><meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no"></head>
        <body>
        <div id="info">
        </div>
        <div id="editor">
          <h2>Demo Content</h2>
          <p>Preset build with <code>snow</code> theme, and some common formats.</p>
        </div>

        <script>
          
        </script>
        </body>
        </html>
        """
        
        let webView = WKWebView(frame: .zero, configuration: wkConfig)
        webView.loadHTMLString(htmlString, baseURL: nil)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
    }
}

#Preview {
    struct Playground: View {
        var body: some View {
            MarkdownEditor()
                .padding()
                .background(.red)
        }
    }
    
    return Playground()
}
