//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/23.
//

import SwiftUI
import WebKit
import Combine

public struct RichTextCommon {}

// MARK: - WKConfig
extension RichTextCommon {
    static func makeWKConfig() -> WKWebViewConfiguration {
        let wkConfig = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 注入 JS
        self.injectQuillScript(userContentController)
        self.injectCssScript(userContentController)
        self.injectBundleScript(userContentController)
        
        wkConfig.userContentController = userContentController
        
        return wkConfig
    }
    
    private static func injectQuillScript(_ userContentController: WKUserContentController) {
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
    
    private static func injectBundleScript(_ userContentController: WKUserContentController) {
        let bundleJsURL = Bundle.module.url(forResource: "bundle.min", withExtension: "js")
        
        guard
            let bundleJsURL,
            let bundleJSString = try? String(contentsOf: bundleJsURL)
        else {
            return
        }
                    
        let bundleScript = WKUserScript(source: bundleJSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(bundleScript)
    }
            
    private static func injectCssScript(_ userContentController: WKUserContentController) {
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
}

// MARK: - webview
extension RichTextCommon {
    struct EditorOptions {
        let readOnly: Bool
        let placeholder: String
        
        init(readOnly: Bool = false, placeholder: String = "备注") {
            self.readOnly = readOnly
            self.placeholder = placeholder
        }
    }
    
    static func updateWebView(
        _ webView: WKWebView,
        editorOptions: EditorOptions,
        navDelegate: WKNavigationDelegate
    ) {
        webView.navigationDelegate = navDelegate
        webView.loadHTMLString(self.genInitHTML(editorOptions), baseURL: nil)
        webView.isInspectable = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
    }
    
    private static func genInitHTML(_ options: EditorOptions) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta
                name="viewport"
                content="width=device-width, initial-scale=1.0, maximum-scale=1, shrink-to-fit=no"
            />
            <style>
                @media (prefers-color-scheme: dark) {
                    body {
                        background-color: #1c1c1e;
                        color: white;
                    }
                    #editor .ql-editor.ql-blank::before {
                        color: #a4a4a5;
                    }
                }
                body {
                    margin: 0;
                    height: 100%;
                    overflow: scroll;
                }
                #editor.ql-container.ql-snow {
                    border: none;
                    font-size: 16px;
                }
                #editor .ql-editor {
                    padding: 10px;
                }
                #editor .ql-editor ol {
                    padding-left: 0;
                }
            </style>
            <script>
                window.tl_editor_config = {
                    readOnly: \(options.readOnly ? "true" : "false"),
                    placeholder: "\(options.placeholder)"
                }
            </script>
        </head>
        <body>
        <div id="editor"></div>
        </body>
        </html>
        """
    }
}

protocol RichTextWebView {
    var viewModel: RichTextCommon.ViewModel { get }
}

// MARK: - Coordinator
extension RichTextCommon {
    class Coordinator: NSObject, WKNavigationDelegate {
        var bridge: JSBridge
        private weak var viewModel: ViewModel?
        private weak var webview: WKWebView?
        private var cancellable: AnyCancellable?
        private var webViewFinished: Bool = false
        private var latestData: String?
        private var lastFetchId: String?
        private var webViewHeight: Binding<CGFloat>

        init(viewModel: ViewModel, height: Binding<CGFloat>) {
            let bridge = JSBridge()
            
            self.viewModel = viewModel
            self.webViewHeight = height
            self.bridge = bridge
            
            super.init()
            
            // 处理前端发过来的消息
            self.cancellable = self.bridge
                .eventBus
                .filter { message in
                    message.eventName == Web2NativeEvent.editorContentChange.rawValue
                }
                .map { msg in
                    msg.data ?? ""
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: {[weak self] data in
                    guard let msg = JSONUtils.decode(data, type: ContentChangeMessageFromJS.self) else {
                        return
                    }
                    
                    self?.latestData = msg.content
                    Task {
                        await viewModel.updateContent(msg.content)
                    }
                })
        }
        
        private func parseContentChangeMessage(_ jsonString: String?) -> ContentChangeMessageFromJS? {
            guard let data = jsonString?.data(using: .utf8) else {
                return nil
            }
            let decoder = JSONDecoder()
            
            guard let msg = try? decoder.decode(ContentChangeMessageFromJS.self, from: data) else {
                return nil
            }
            
            return msg
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webViewFinished = true
            self.updateWebview(webView)
            if let viewModel {
                self.syncContent(viewModel.content)
            }
            self.updateWebViewHeight()
        }
        
        /**
         *  不能在此函数中使用 parent.content 进行判断，
         *  当 parent.content 更新时，这里获取到的是旧值
         */
        func syncContent(_ newContent: String) {
            guard webViewFinished, latestData != newContent else {
                self.updateWebViewHeight()
                return
            }
            
            latestData = newContent
            bridge.trigger(
                eventName: Native2WebEvent.editorSetContent.rawValue,
                data: newContent
            )
            self.updateWebViewHeight()
        }
        
        func fetchContent() {
            Task { @MainActor [weak self] in
                guard let self, let viewModel else {
                    return
                }
                
                // 首次执行，不需要获取内容
                if self.lastFetchId == nil {
                    self.lastFetchId = viewModel.fetchContentId
                    return
                }
                
                // 没有请求过
                guard self.lastFetchId != viewModel.fetchContentId else {
                    return
                }
                self.lastFetchId = viewModel.fetchContentId
                guard let result = await self.bridge.callJS(
                    eventName: NativeCallWebEvent.editorFetchContent.rawValue
                ) else {
                    viewModel.finishSync(nil)
                    return
                }
                
                self.latestData = result
                viewModel.finishSync(result)
            }
        }
        
        func updateWebview(_ webview: WKWebView) {
            if webview != self.webview {
                self.webview = webview
                self.removeKeyboardObserver()
                self.bridge.updateWebview(webview)
            }
        }
        
        private func removeKeyboardObserver() {
            guard let webview else {
                return
            }
            NotificationCenter.default.removeObserver(webview, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.removeObserver(webview, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(webview, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        private func updateWebViewHeight() {
            Task {
                guard let height = await bridge.getConentHeight() else {
                    return
                }
                
                DispatchQueue.main.async {
                    if self.webViewHeight.wrappedValue != height {
                        self.webViewHeight.wrappedValue = height
                    }
                }
            }
        }
    }
}

// MARK: - event name
extension RichTextCommon {
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
        case editorContentChange = "editor.contentChange"
    }
    
    enum NativeCallWebEvent: String {
        case editorFetchContent = "editor.fetchContent"
    }
    
    struct ContentChangeMessageFromJS: Codable {
        let content: String
        let lines: Int
    }
}

// MARK: - ViewModel
extension RichTextCommon {
    public class ViewModel: ObservableObject {
        // 用于主动获取 web content 的标识
        @Published var fetchContentId: String = UUID().uuidString
        @Published public private(set) var content: String
        
        private var cancelable: AnyCancellable?
        private let syncStream = PassthroughSubject<String, Never>()
        
        public init(
            _ content: String = ""
        ) {
            self.content = content
        }
        
        @MainActor
        public func updateContent(_ newContent: String) {
            if newContent != self.content {
                self.content = newContent
            }
        }
        
        // 与 web 同步 content
        @MainActor
        public func syncContent() async -> String {
            let newId = UUID().uuidString
            let oldContent = self.content
            self.fetchContentId = newId
            
            let newContent = await withCheckedContinuation {[weak self] continuation in
                if let cancel = self?.cancelable {
                    cancel.cancel()
                }
                
                var cancelable: AnyCancellable?
                cancelable = self?.syncStream
                    .prefix(1)
                    .receive(on: RunLoop.main)
                    .sink { content in
                        if self?.cancelable == cancelable {
                            self?.cancelable = nil
                        }
                        continuation.resume(returning: content)
                    }
                
                self?.cancelable = cancelable
            }
            
            // 保证没有新的请求发出
            guard newId == self.fetchContentId else {
                return self.content
            }
            
            // 保证 content 未更新
            guard oldContent == self.content else {
                return self.content
            }
            
            self.content = newContent
            return newContent
        }
        
        @MainActor
        func finishSync(_ newContent: String?) {
            if let newContent {
                self.updateContent(newContent)
                self.syncStream.send(newContent)
            } else {
                self.syncStream.send(self.content)
            }
        }
    }
}
