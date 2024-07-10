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
        var handleBoldButtonTapped: (() -> Void)?
        var handleNumberListButtonTapped: (() -> Void)?
        var handleDashListButtonTapped: (() -> Void)?
        var handleCheckBoxListButtonTapped: (() -> Void)?
        var handleIncreaseIndentButtonTapped: (() -> Void)?
        var handleDecreaseIndentButtonTapped: (() -> Void)?
        var handleHideKeyboardButtonTapped: (() -> Void)?
    
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupViews()
        }
        
        private func setupViews() {
            let toolbar = UIToolbar(frame: .zero)
            toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let boldButton = UIBarButtonItem(
                image: UIImage(systemName: "bold"),
                style: .plain,
                target: self,
                action: #selector(onBoldButtonTapped)
            )
            let numberListButton = UIBarButtonItem(
                image: UIImage(systemName: "list.number"),
                style: .plain,
                target: self,
                action: #selector(onNumberListButtonTapped)
            )
            let dashListButton = UIBarButtonItem(
                image: UIImage(systemName: "list.dash"),
                style: .plain,
                target: self,
                action: #selector(onDashListButtonTapped)
            )
            let checkBoxListButton = UIBarButtonItem(
                image: UIImage(systemName: "checklist"),
                style: .plain,
                target: self,
                action: #selector(onCheckBoxListButtonTapped)
            )
            let increaseIndentButton = UIBarButtonItem(
                image: UIImage(systemName: "increase.indent"),
                style: .plain,
                target: self,
                action: #selector(onIncreaseIndentButtonTapped)
            )
            let decreaseIndentButton = UIBarButtonItem(
                image: UIImage(systemName: "decrease.indent"),
                style: .plain,
                target: self,
                action: #selector(onDecreaseIndentButtonTapped)
            )
            let rightSpace = UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            )
            let hideKeyboardButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.down"),
                style: .plain,
                target: self,
                action: #selector(onHideKeyboardButtonTapped)
            )
            
            toolbar.items = [
                boldButton,
                dashListButton,
                numberListButton,
                checkBoxListButton,
                increaseIndentButton,
                decreaseIndentButton,
                rightSpace,
                hideKeyboardButton
            ]
            
            toolbar.items?.forEach({ item in
                item.tintColor = .darkGray
            })
            
            addSubview(toolbar)
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
        
        @objc func onBoldButtonTapped() {
            handleBoldButtonTapped?()
        }
        
        @objc func onNumberListButtonTapped() {
            handleNumberListButtonTapped?()
        }
        
        @objc func onDashListButtonTapped() {
            handleDashListButtonTapped?()
        }
        
        @objc func onCheckBoxListButtonTapped() {
            handleCheckBoxListButtonTapped?()
        }
        
        @objc func onIncreaseIndentButtonTapped() {
            handleIncreaseIndentButtonTapped?()
        }
        
        @objc func onDecreaseIndentButtonTapped() {
            handleDecreaseIndentButtonTapped?()
        }
        
        @objc func onHideKeyboardButtonTapped() {
            handleHideKeyboardButtonTapped?()
        }
    }
}

extension MarkdownEditor {
    struct WebView: UIViewRepresentable {
        private var bridge: JSBridge
        
        init() {
            self.bridge = JSBridge()
        }
        
        func makeUIView(context: Context) -> WKWebView {
            let wkConfig = WKWebViewConfiguration()
            let userContentController = WKUserContentController()
            
            // 注入 JS
            self.injectQuillScript(userContentController)
            self.injectCssScript(userContentController)
            self.injectBundleScript(userContentController)
            
            wkConfig.userContentController = userContentController
                    
            let webView = CustomAccessoryWebView(frame: .zero, configuration: wkConfig)
            webView.loadHTMLString(self.genInitHTML(), baseURL: nil)
            webView.isInspectable = true
            
            webView.myAccessoryView = self.setupToolbar()
            webView.myAccessoryView?.frame = .init(x: 0, y: 0, width: 50, height: 50)
                        
            self.bridge.updateWebview(webView)
            
            return webView
        }
        
        func updateUIView(_ webView: WKWebView, context: Context) {
            self.bridge.updateWebview(webView)
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
        
        private func injectBundleScript(_ userContentController: WKUserContentController) {
            let bundleJsURL = Bundle.module.url(forResource: "bundle", withExtension: "js")
            
            guard
                let bundleJsURL,
                let bundleJSString = try? String(contentsOf: bundleJsURL)
            else {
                return
            }
                        
            let bundleScript = WKUserScript(source: bundleJSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(bundleScript)
        }
        
        private func injectCssScript(_ userContentController: WKUserContentController) {
            // 加载 js\css 文件
            let quillCssURL = Bundle.module.url(forResource: "quill.snow", withExtension: "css")
            
            var finalCssString = ""
            if
                let quillCssURL,
                let quillCssString = try? String(contentsOf: quillCssURL, encoding: .utf8)
            {
                finalCssString = quillCssString
                    .trimmingCharacters(in: .newlines)
                    .replacingOccurrences(of: "\\", with: "\\\\") // 处理 unicode 中的 \
                    .replacingOccurrences(of: "\"", with: "\\\"") // 处理 "
                    
            }
            
            let createStyleJSString = """
            const style = document.createElement('style');
            style.type = "text/css";
            style.innerHTML = "\(finalCssString)";
            document.head.append(style);
            """
            let createStyleScript = WKUserScript(source: createStyleJSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userContentController.addUserScript(createStyleScript)
        }
        
        private func genInitHTML() -> String {
            return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta 
                    name="viewport"
                    content="width=device-width, initial-scale=1.0, maximum-scale=1, shrink-to-fit=no"
                />
                <style>
                  body {
                    margin: 0;
                  }
                  body > .ql-container.ql-snow {
                    border: none;
                  }
                </style>
            </head>
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
        
        private func setupToolbar() -> KeyboardToolbar {
            let toolbar = KeyboardToolbar()
            toolbar.backgroundColor = .darkGray
            
            // 触发事件
            toolbar.handleBoldButtonTapped = handleButtonTapped(.boldButtonTapped)
            toolbar.handleDashListButtonTapped = handleButtonTapped(.dashListButtonTapped)
            toolbar.handleNumberListButtonTapped = handleButtonTapped(.numberListButtonTapped)
            toolbar.handleCheckBoxListButtonTapped = handleButtonTapped(.checkBoxListButtonTapped)
            toolbar.handleIncreaseIndentButtonTapped = handleButtonTapped(.increaseIndentButtonTapped)
            toolbar.handleDecreaseIndentButtonTapped = handleButtonTapped(.decreaseIndentButtonTapped)
            toolbar.handleHideKeyboardButtonTapped = handleButtonTapped(.blurButtonTapped)
            
            return toolbar
        }
        
        private func handleButtonTapped(_ eventName: Native2WebEvent) -> () -> Void {
            {
                bridge.trigger(eventName: eventName.rawValue)
            }
        }
    }
}

extension MarkdownEditor.WebView {
    enum Native2WebEvent: String {
        case boldButtonTapped = "toolbar.boldButtonTapped"
        case numberListButtonTapped = "toolbar.numberListButtonTapped"
        case dashListButtonTapped = "toolbar.dashListButtonTapped"
        case checkBoxListButtonTapped = "toolbar.checkBoxListButtonTapped"
        case increaseIndentButtonTapped = "toolbar.increaseIndentButtonTapped"
        case decreaseIndentButtonTapped = "toolbar.decreaseIndentButtonTapped"
        case blurButtonTapped = "toolbar.blurButtonTapped"
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
    bar.backgroundColor = .red
    
    return bar
}
