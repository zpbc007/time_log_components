//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2025/1/13.
//

import SwiftUI

public struct PickerWithImage<T: Identifiable & Equatable, C: RandomAccessCollection<T>, Content: View>: View  {
    @Environment(\.colorScheme) 
    private var colorScheme
    
    let items: C
    @Binding var selection: T
    @ViewBuilder let itemBuilder: (T) -> Content
    
    public init(
        items: C,
        selection:Binding<T>,
        itemBuilder: @escaping (T) -> Content
    ) {
        self.items = items
        self._selection = selection
        self.itemBuilder = itemBuilder
    }
    
    private var activeColor: Color {
        colorScheme == .dark ? .gray.opacity(0.6) : .white
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { source in
                Button {
                    selection = source
                } label: {
                    itemBuilder(source)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(
                            selection == source
                            ? activeColor
                            : Color.clear
                        )
                        .cornerRadius(5)
                        .foregroundColor(Color(uiColor: .label))
                }
                .buttonStyle(PlainButtonStyle())
                .animation(.easeInOut, value: selection)
            }
        }
        .padding(2)
        .background(Color.gray.opacity(0.4))
        .cornerRadius(5)
    }
}

#Preview {
    struct Item: Identifiable, Equatable {
        let name: String
        let sfName: String
        
        var id: String {
            name
        }
    }
    
    struct Playground: View {
        static let items: [Item] = [
            .init(name: "生存", sfName: "flame.circle"),
            .init(name: "工作", sfName: "building.2.crop.circle"),
            .init(name: "自由", sfName: "steeringwheel.circle")
        ]
        @State private var selection: Item = Self.items[0]
        
        var body: some View {
            PickerWithImage(items: Self.items, selection: $selection) { item in
                HStack {
                    Image(systemName: item.sfName)
                    Text(item.name)
                }.font(.callout)
            }
        }
    }
    
    return Playground()
}

#Preview("Color") {
    ScrollView {
        VStack {
            ForEach([
                UIColor.label,
                UIColor.secondaryLabel,
                UIColor.tertiaryLabel,
                UIColor.systemFill,
                UIColor.secondarySystemFill,
                UIColor.tertiarySystemFill,
                UIColor.quaternarySystemFill,
                UIColor.lightText,
                UIColor.darkText,
                UIColor.lightGray
            ], id: \.self) { color in
                HStack {
                    Text(String(describing: color))
                    Spacer()
                    Color(uiColor: color)
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
}
