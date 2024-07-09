//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/9.
//

import SwiftUI
import WebKit

public struct MarkdownEditor: View {
    @State private var input = ""
    
    public init() {}
    
    public var body: some View {
        WebView()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("hide") {
                    
                }
            }
        }
    }
}

extension MarkdownEditor {
    class CustomAccessoryWebView: WKWebView {
        override init(frame: CGRect, configuration: WKWebViewConfiguration) {
            super.init(frame: frame, configuration: configuration)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        var myAccessoryView: UIView?
        override var inputAccessoryView: UIView? {
            myAccessoryView
        }
    }
}

extension MarkdownEditor {
    class KeyboardToolbar: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupViews()
        }
        
        private func setupViews() {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .leading
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(stackView)

            let spacer = UIView()
            spacer.backgroundColor = .clear
            spacer.isUserInteractionEnabled = false
            
            stackView.addArrangedSubview(buildButton("button1"))
            stackView.addArrangedSubview(buildButton("button2"))
            stackView.addArrangedSubview(buildButton("button3"))
            stackView.addArrangedSubview(spacer)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
            ])
        }
        
        private func buildButton(_ text: String) -> UIButton {
            let button = UIButton(type: .system)
            button.setTitle(text, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            return button
        }
        
        @objc func buttonTapped() {
            // 处理按钮点击事件
            print("Button was tapped")
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
                    
            let webView = CustomAccessoryWebView(frame: .zero, configuration: wkConfig)
            webView.loadHTMLString(self.genInitHTML(), baseURL: nil)
            webView.isInspectable = true
            webView.myAccessoryView = KeyboardToolbar()
            webView.myAccessoryView?.frame = .init(x: 0, y: 0, width: 50, height: 50)
            
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
            }
        }
    }
    
    return Playground()
}

#Preview("toolbar") {
    let bar = MarkdownEditor.KeyboardToolbar()
//    bar.backgroundColor = .red
    
    return bar
}
