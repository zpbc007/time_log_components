//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/7/11.
//

import Foundation

public struct TimeLogSelectable: Equatable, Identifiable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
