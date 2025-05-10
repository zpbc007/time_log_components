//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/7/22.
//

import Foundation

extension Double {
    public func formatInterval() -> String {
        var target = self
        if self.isNaN || self.isInfinite {
            target = 0.0
        }
        
        let intervalFormatter: DateComponentsFormatter = .init()
        intervalFormatter.unitsStyle = .abbreviated
        intervalFormatter.allowedUnits = [.day, .hour, .minute]
        
        return intervalFormatter.string(from: target) ?? ""
    }
}
