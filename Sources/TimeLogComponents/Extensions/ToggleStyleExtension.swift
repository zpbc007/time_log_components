//
//  File.swift
//  
//
//  Created by zhaopeng on 2024/6/24.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(
                systemName: configuration.isOn
                    ? "checkmark.square"
                    : "square"
            )
            .onTapGesture {
                withAnimation(.spring()) {
                    configuration.isOn.toggle()
                }
            }

            configuration.label
        }
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkmark: CheckboxToggleStyle { CheckboxToggleStyle() }
}

