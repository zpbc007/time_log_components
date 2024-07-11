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
    
    private weak var webview: WKWebView?
    
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
        let callbackID: String?
        let data: String?
    }
    
    func updateWebview(_ webview: WKWebView) {
        if webview == self.webview {
            return
        }
        self.removeJSBMessageHandler()
        self.webview = webview
        self.addJSBMessageHandler()
    }
    
    func trigger(eventName: String) {
        let msg = JSBMessageFromNative<String>(eventName: eventName, data: nil)
        dispatch(msg)
    }
    
    func trigger<D: Codable>(eventName: String, data: D) {
        let msg = JSBMessageFromNative(eventName: eventName, data: data)
        dispatch(msg)
    }
    
    func callJS(eventName: String) async -> String? {
        let msg = JSBMessageFromNative<String>(eventName: eventName, data: nil)
        guard let msgJSON = serialize(msg) else {
            return nil
        }
        
        let jsCommand = "window.timeLineBridge._handleEventFromNative('\(msgJSON)')"
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async { [weak self] in
                self?.webview?.evaluateJavaScript(jsCommand, completionHandler: { resultString, _ in
                    guard let jsonString = resultString as? String else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    continuation.resume(returning: jsonString)
                })
            }
        }
    }
    
    func response<D: Codable>(eventName: String, callbackID: String, data: D) {
        let msg = JSBMessageFromNative(eventName: eventName, callbackID: callbackID, data: data)
        dispatch(msg)
    }
    
    deinit {
        removeJSBMessageHandler()
    }
    
    func deserialize<T : Decodable>(_ jsonString: String?, type: T.Type) -> T? {
        guard let json = jsonString?.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        
        return try? decoder.decode(type, from: json)
    }
    
    private func addJSBMessageHandler() {
        webview?.configuration.userContentController.add(LeakAvoider(self.handleJSMessage), name: Self.JSBName)
    }
    
    private func removeJSBMessageHandler() {
        webview?.configuration.userContentController.removeScriptMessageHandler(forName: Self.JSBName)
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
        let encoder = JSONEncoder()

        guard
            let data = try? encoder.encode(message),
            var json = String(data: data, encoding: .utf8) else {
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
