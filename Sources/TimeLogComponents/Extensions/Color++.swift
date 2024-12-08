//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/12/8.
//

import Foundation
import SwiftUI

/// 让 Color 满足 Codable 协议
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
        
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let a = try container.decode(Double.self, forKey: .alpha)
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let (r, g, b, a) = toRGBA() else {
            return
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(r, forKey: .red)
        try container.encode(g, forKey: .green)
        try container.encode(b, forKey: .blue)
        try container.encode(a, forKey: .alpha)
    }
}

extension Color {
    public static func hexString2RGBA(hexString: String) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
        guard hexString.hasPrefix("#") else {
            return nil
        }
        
        let start = hexString.index(hexString.startIndex, offsetBy: 1)
        let hexColor = String(hexString[start...])
        
        guard hexColor.count == 8 else {
            return nil
        }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            let g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            let b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            let a = CGFloat(hexNumber & 0x000000ff) / 255
            
            return (r: r, g: g, b: b, a: a)
        }
        
        return nil
    }
}

extension Color {
    public init(hexString: String) {
        if let (r, g, b, a) = Self.hexString2RGBA(hexString: hexString) {
            self.init(red: r, green: g, blue: b, opacity: a)
        } else {
            self.init(.black)
        }
    }
    
    public func toRGBA() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        /// 获取 RGBA 信息
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return nil
        }
        
        r = max(0, min(1, r))
        g = max(0, min(1, g))
        b = max(0, min(1, b))
        a = max(0, min(1, a))
        
        return (r: r, g: g, b: b, a: a)
    }
    
    public func toHexString() -> String {
        let (r, g, b, a) = self.toRGBA() ?? (r: 0, g: 0, b: 0, a: 1)
        
        return String(
            format: "#%02X%02X%02X%02X",
            Int(round(r * 255)),
            Int(round(g * 255)),
            Int(round(b * 255)),
            Int(round(a * 255))
        )
    }
}
