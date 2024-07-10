//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/7/10.
//

import Foundation
import SwiftUI
import WebKit
import Combine

class LeakAvoider: NSObject {
    let delegate: (String?) -> Void
    
    init(_ delegate: @escaping (String?) -> Void) {
        self.delegate = delegate
        super.init()
    }
}

extension LeakAvoider: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let msgJSONString = message.body as? String
        
        delegate(msgJSONString)
    }
}


public class JSBridge {
    static let JSBName = "timeLineBridge"
    
    weak var webview: WKWebView?
    
    init(webview: WKWebView) {
        self.webview = webview
        addJSBMessageHandler()
    }
    
    let eventBus = PassthroughSubject<JSBMessageFromJS, Never>()
    
    struct JSBMessageFromNative<D: Codable>: Codable {
        let eventName: String
        let callbackID: String?
        let data: D?
        
        init(eventName: String, callbackID: String? = nil, data: D?) {
            self.eventName = eventName
            self.callbackID = callbackID
            self.data = data
        }
    }
    
    struct JSBMessageFromJS: Codable {
        let eventName: String
        let data: Data
    }
    
    func trigger(eventName: String) {
        let msg = JSBMessageFromNative<Never>(eventName: eventName, data: nil)
        dispatch(msg)
    }
    
    func trigger<D: Codable>(eventName: String, data: D) {
        let msg = JSBMessageFromNative(eventName: eventName, data: data)
        dispatch(msg)
    }
    
    func response<D: Codable>(eventName: String, callbackID: String, data: D) {
        let msg = JSBMessageFromNative(eventName: eventName, callbackID: callbackID, data: data)
        dispatch(msg)
    }
    
    private func addJSBMessageHandler() {
        webview?.configuration.userContentController.add(LeakAvoider(self.handleJSMessage), name: Self.JSBName)
    }
    
    private func dispatch<D: Codable>(_ message: JSBMessageFromNative<D>) {
        guard let msgJSON = serialize(message) else {
            return
        }
        
        let jsCommand = "window.timeLineBridge._handleMessageFromNative('\(msgJSON)')"
        
        DispatchQueue.main.async { [weak self] in
            self?.webview?.evaluateJavaScript(jsCommand)
        }
    }
    
    private func serialize<D: Codable>(_ message: JSBMessageFromNative<D>) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: message) else {
            return nil
        }
        
        guard var json = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        json = json.replacingOccurrences(of: "\\", with: "\\\\")
        json = json.replacingOccurrences(of: "\"", with: "\\\"")
        json = json.replacingOccurrences(of: "\'", with: "\\\'")
        json = json.replacingOccurrences(of: "\n", with: "\\n")
        json = json.replacingOccurrences(of: "\r", with: "\\r")
        json = json.replacingOccurrences(of: "\u{000C}", with: "\\f")
        json = json.replacingOccurrences(of: "\u{2028}", with: "\\u2028")
        json = json.replacingOccurrences(of: "\u{2029}", with: "\\u2029")
        
        return json
    }
    
    private func handleJSMessage(_ msgJSONString: String?){
        guard let data = msgJSONString?.data(using: .utf8) else {
            return
        }
        let decoder = JSONDecoder()
        
        guard let msg = try? decoder.decode(JSBMessageFromJS.self, from: data) else {
            return
        }
        
        eventBus.send(msg)
    }
}
