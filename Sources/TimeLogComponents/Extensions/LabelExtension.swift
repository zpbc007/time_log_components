//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import Foundation
import SwiftUI

struct RoundedCornerLabelStyle: LabelStyle {
    @ScaledMetric(relativeTo: .footnote) private var iconWidth = 14.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 3) {
            configuration.icon
                .frame(width: iconWidth)
            
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
