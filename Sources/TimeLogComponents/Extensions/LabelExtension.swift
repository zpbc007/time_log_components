//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import Foundation
import SwiftUI

struct RoundedCornerLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 3) {
            configuration.icon
            
            configuration.title
        }
        .padding(6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}

extension LabelStyle where Self == RoundedCornerLabelStyle {
    static var roundedCornerTag: RoundedCornerLabelStyle {
        RoundedCornerLabelStyle()
    }
}
