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
    let placeholder: String
    let maxHeight: CGFloat
    @State private var height: CGFloat = 10
    
    public init(placeholder: String, maxHeight: CGFloat = .infinity) {
        self.placeholder = placeholder
        self.maxHeight = maxHeight
    }
    
    private var webViewHeight: CGFloat {
        max(15, min(height, maxHeight))
    }
    
    public var body: some View {
        WebView(placeholder: placeholder, height: $height)
            .frame(height: webViewHeight)
            .animation(.linear, value: height)
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
                item.tintColor = UIColor.init { (trait) -> UIColor in
                    return trait.userInterfaceStyle == .dark ? .lightGray : .darkGray
                }
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
    public typealias ViewModel = RichTextCommon.ViewModel
}

extension RichTextEditor {
    struct WebView: UIViewRepresentable, RichTextWebView {
        let placeholder: String
        @EnvironmentObject var viewModel: RichTextCommon.ViewModel
        @Binding var height: CGFloat
        
        init(placeholder: String, height: Binding<CGFloat>) {
            self.placeholder = placeholder
            self._height = height
        }
        
        func makeUIView(context: Context) -> WKWebView {
            let wkConfig = RichTextCommon.makeWKConfig()
            let webView = CustomAccessoryWebView(frame: .zero, configuration: wkConfig)
            
            // webview config
            RichTextCommon.updateWebView(
                webView,
                editorOptions: .init(readOnly: false, placeholder: placeholder),
                navDelegate: context.coordinator
            )
            // tool bar
            webView.myAccessoryView = self.setupToolbar(context.coordinator)
            webView.myAccessoryView?.frame = .init(x: 0, y: 0, width: 50, height: 50)
            // bridge
            context.coordinator.updateWebview(webView)
            
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
        
        private func handleButtonTapped(
            _ coordinator: Coordinator,
            _ eventName: RichTextCommon.Native2WebEvent
        ) -> () -> Void {
            {
                coordinator.bridge.trigger(eventName: eventName.rawValue)
            }
        }
    }
}

#Preview("normal") {
    struct Playground: View {
        @StateObject 
        private var editorVM = RichTextEditor.ViewModel(
//            "{\"ops\":[{\"insert\":\"Gandalf\",\"attributes\":{\"bold\":true}}]}"
        )
        
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
                    
                    RichTextEditor(placeholder: "xxx")
                        .environmentObject(editorVM)
                        .border(.black)
                        .padding()
                }
            }
        }
    }
    
    return Playground()
}

#Preview("maxHeight") {
    struct Playground: View {
        @StateObject
        private var editorVM = RichTextEditor.ViewModel(
            "{\"ops\":[{\"insert\":\"Gandalf\",\"attributes\":{\"bold\":true}}]}"
        )
        
        var body: some View {
            NavigationStack {
                VStack(spacing: 0) {
                    VStack {
                        Text("top")
                    }
                    Spacer()
                    
                    RichTextEditor(placeholder: "yyy", maxHeight: 300)
                        .environmentObject(editorVM)
                        .border(.black)
                    
                    Text("Buttom")
                }
            }
        }
    }
    
    return Playground()
}

#Preview("toolbar") {
    let bar = RichTextEditor.KeyboardToolbar()
    bar.backgroundColor = .white
    
    return bar
}
