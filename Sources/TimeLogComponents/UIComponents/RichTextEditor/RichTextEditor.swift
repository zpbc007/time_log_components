//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/9.
//

import SwiftUI
import WebKit
import Combine

public struct RichTextEditor: View {
    public var body: some View {
        WebView()
    }
}

extension RichTextEditor {
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

extension RichTextEditor {
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

extension RichTextEditor {
    public class ViewModel: ObservableObject {
        // 用于主动获取 web content 的标识
        @Published var fetchContentId: String = UUID().uuidString
        @Published public private(set) var content: String
        
        private var cancelable: AnyCancellable?
        private let syncStream = PassthroughSubject<String, Never>()
        
        public init(_ content: String = "") {
            self.content = content
        }
        
        public func updateContent(_ newContent: String) {
            if newContent != self.content {
                self.content = newContent
            }
        }
        
        // 与 web 同步 content
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
                    .sink { content in
                        if self?.cancelable == cancelable {
                            self?.cancelable = nil
                        }
                        print("resume")
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

extension RichTextEditor {
    struct WebView: UIViewRepresentable {
        @EnvironmentObject var viewModel: RichTextEditor.ViewModel
        
        func makeUIView(context: Context) -> WKWebView {
            let wkConfig = WKWebViewConfiguration()
            let userContentController = WKUserContentController()
            
            // 注入 JS
            self.injectQuillScript(userContentController)
            self.injectCssScript(userContentController)
            self.injectBundleScript(userContentController)
            
            wkConfig.userContentController = userContentController
                    
            let webView = CustomAccessoryWebView(frame: .zero, configuration: wkConfig)
            webView.navigationDelegate = context.coordinator
            webView.loadHTMLString(self.genInitHTML(), baseURL: nil)
            webView.isInspectable = true
            
            webView.myAccessoryView = self.setupToolbar(context.coordinator)
            webView.myAccessoryView?.frame = .init(x: 0, y: 0, width: 50, height: 50)
                        
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
                    #editor.ql-container.ql-snow {
                        border: none;
                        font-size: 16px;
                    }
                    #editor .ql-editor {
                        padding: 0;
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
    }
}

extension RichTextEditor.WebView {
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: RichTextEditor.WebView
        var bridge: JSBridge
        private var cancellable: AnyCancellable?
        private var webViewFinished: Bool = false
        private var latestData: String?
        private var lastFetchId: String?

        init(_ parent: RichTextEditor.WebView) {
            let bridge = JSBridge()
            
            self.parent = parent
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
                    self?.latestData = data
                    parent.viewModel.updateContent(data)
                })
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webViewFinished = true
            self.syncContent(parent.viewModel.content)
        }
        
        /**
         *  不能在此函数中使用 parent.content 进行判断，
         *  当 parent.content 更新时，这里获取到的是旧值
         */
        func syncContent(_ newContent: String) {
            guard webViewFinished, latestData != newContent else {
                return
            }
            
            latestData = newContent
            bridge.trigger(
                eventName: Native2WebEvent.editorSetContent.rawValue,
                data: newContent
            )
        }
        
        func fetchContent() {
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }
                
                // 首次执行，不需要获取内容
                if self.lastFetchId == nil {
                    self.lastFetchId = self.parent.viewModel.fetchContentId
                    return
                }
                
                // 没有请求过
                guard self.lastFetchId != self.parent.viewModel.fetchContentId else {
                    return
                }
                self.lastFetchId = self.parent.viewModel.fetchContentId
                guard let result = await self.bridge.callJS(
                    eventName: NativeCallWebEvent.editorFetchContent.rawValue
                ) else {
                    self.parent.viewModel.finishSync(nil)
                    return
                }
                
                self.latestData = result
                self.parent.viewModel.finishSync(result)
            }
        }
    }
}

extension RichTextEditor.WebView {
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
}

#Preview {
    struct Playground: View {
        @StateObject private var editorVM = RichTextEditor.ViewModel("{\"ops\":[{\"insert\":\"Gandalf\",\"attributes\":{\"bold\":true}}]}")
        
        var body: some View {
            NavigationStack {
                VStack {
                    Text(editorVM.content)
                    
                    Button("set") {
                        editorVM.updateContent("{\"ops\":[{\"insert\":\"Gandalf\",\"attributes\":{\"bold\":true}},{\"insert\":\" the \"},{\"insert\":\"Grey\",\"attributes\":{\"color\":\"#cccccc\"}}]}")
                    }
                    Button("save") {
                        Task { @MainActor in
                            let content = await editorVM.syncContent()
                            print("get content: ", content)
                        }
                    }
                    
                    RichTextEditor()
                        .environmentObject(editorVM)
                }
            }
        }
    }
    
    return Playground()
}

#Preview("toolbar") {
    let bar = RichTextEditor.KeyboardToolbar()
    bar.backgroundColor = .red
    
    return bar
}
