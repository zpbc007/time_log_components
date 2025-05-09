//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/10/16.
//

import SwiftUI

extension TLCalendar {
    struct DayView: View {
        let date: Date
        let foreground: Color
        let disabledForeground: Color
        let selectionForeground: Color
        let selectionBG: Color
        let disabled: Bool
        @Binding var selected: Date
        
        var body: some View {
            ZStack(alignment: .center) {
                SelectedView
                DayLabelView
            }
            .animation(.easeInOut, value: isSelected)
            .onTapGesture {
                selected = date
            }
        }
        
        private var isSelected: Bool {
            date.isSame(day: selected)
        }
        
        private var foregroundColor: Color {
            if disabled {
                return disabledForeground
            }
            
            return isSelected ? selectionForeground : foreground
        }
        
        @ViewBuilder
        private var DayLabelView: some View {
            Text(date.toString(format: "d"))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
        }
        
        @ViewBuilder
        private var SelectedView: some View {
            Circle()
                .fill(selectionBG)
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.52)
                                .combined(with: .opacity),
                        removal: .opacity
                    )
                )
                .active(if: isSelected)
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var selected: Date = .now
        
        var body: some View {
            VStack {
                TLCalendar.DayView(
                    date: .now,
                    foreground: .black,
                    disabledForeground: .gray,
                    selectionForeground: .red,
                    selectionBG: .green.opacity(0.8),
                    disabled: false,
                    selected: $selected
                )
                .frame(width: 35, height: 35)
//                .animation(.easeInOut, value: selected)
                                
                Button("toggle") {
                    self.selected = self.selected.add(1)
                }
            }
        }
    }
    
    return Playground()
}
