//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/9.
//

import SwiftUI
import WebKit
import Combine

public struct MarkdownEditor: View {
    @Binding var content: String
    
    public init(content: Binding<String>) {
        self._content = content
    }
    
    public var body: some View {
        WebView(content: $content)
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
        @Binding var content: String
        
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
            
            webView.myAccessoryView = self.setupToolbar(context.coordinator)
            webView.myAccessoryView?.frame = .init(x: 0, y: 0, width: 50, height: 50)
                        
            context.coordinator.bridge.updateWebview(webView)
            
            self.syncContent(context.coordinator)
            
            
            return webView
        }
        
        func updateUIView(_ webView: WKWebView, context: Context) {
            context.coordinator.bridge.updateWebview(webView)
            if context.coordinator.latestData != content {
                self.syncContent(context.coordinator)
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
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
            <div id="editor"></div>
            </body>
            </html>
            """
        }
        
        private func setupToolbar(_ coordinator: Coordinator) -> KeyboardToolbar {
            let toolbar = KeyboardToolbar()
            toolbar.backgroundColor = .darkGray
            
            // 触发事件
            toolbar.handleBoldButtonTapped = handleButtonTapped(coordinator, .boldButtonTapped)
            toolbar.handleDashListButtonTapped = handleButtonTapped(coordinator, .dashListButtonTapped)
            toolbar.handleNumberListButtonTapped = handleButtonTapped(coordinator, .numberListButtonTapped)
            toolbar.handleCheckBoxListButtonTapped = handleButtonTapped(coordinator, .checkBoxListButtonTapped)
            toolbar.handleIncreaseIndentButtonTapped = handleButtonTapped(coordinator, .increaseIndentButtonTapped)
            toolbar.handleDecreaseIndentButtonTapped = handleButtonTapped(coordinator, .decreaseIndentButtonTapped)
            toolbar.handleHideKeyboardButtonTapped = handleButtonTapped(coordinator, .blurButtonTapped)
            
            return toolbar
        }
        
        private func handleButtonTapped(_ coordinator: Coordinator, _ eventName: Native2WebEvent) -> () -> Void {
            {
                coordinator.bridge.trigger(eventName: eventName.rawValue)
            }
        }
        
        // 通知 web 重新设置 content
        private func syncContent(_ coordinator: Coordinator) {
            coordinator.bridge.trigger(
                eventName: Native2WebEvent.editorSetContent.rawValue,
                data: content
            )
        }
    }
}

extension MarkdownEditor.WebView {
    class Coordinator: NSObject {
        var parent: MarkdownEditor.WebView
        var bridge: JSBridge
        private var cancellable: AnyCancellable?
        private(set) var latestData: String?

        init(_ parent: MarkdownEditor.WebView) {
            let bridge = JSBridge()
            
            self.parent = parent
            self.bridge = bridge
            
            super.init()
            
            // 处理前端发过来的消息
            self.cancellable = self.bridge
                .eventBus
                .filter { message in
                    message.eventName == Web2NativeEvent.editorTextChange.rawValue
                }
                .map { msg in
                    msg.data ?? ""
                }
                .sink(receiveValue: {[weak self] data in
                    self?.latestData = data
                    if parent.content != data {
                        parent.content = data
                    }
                })
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
        case editorSetContent = "editor.setContent"
    }
    
    enum Web2NativeEvent: String {
        case editorTextChange = "editor.textChange"
    }
}

#Preview {
    struct Playground: View {
        @State private var content = "{\"ops\":[{\"insert\":\"Gandalf\",\"attributes\":{\"bold\":true}}]}"
        
        var body: some View {
            NavigationStack {
                VStack {
                    Button("add") {
                        content = "{\"ops\":[{\"insert\":\"Gandalf\",\"attributes\":{\"bold\":true}},{\"insert\":\" the \"},{\"insert\":\"Grey\",\"attributes\":{\"color\":\"#cccccc\"}}]}"
                    }
                    MarkdownEditor(content: $content)
                }
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
