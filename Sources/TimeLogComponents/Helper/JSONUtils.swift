//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/10/23.
//

import Foundation

struct JSONUtils {
    static func decode<T: Codable>(_ jsonString: String, type: T.Type) -> T? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        
        guard let msg = try? decoder.decode(type, from: data) else {
            return nil
        }
        
        return msg
    }
}
