//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/22.
//

import SwiftUI
import Charts
import IdentifiedCollections

public struct LineChart: View {
    @Environment(\.colorScheme) private var colorScheme
    let values: IdentifiedArrayOf<Value>
    
    public init(values: IdentifiedArrayOf<Value>) {
        self.values = values
    }
    
    var totalDuration: Double {
        values.reduce(into: 0.0) { partialResult, item in
            partialResult += item.duration
        }
    }
    
    public var body: some View {
        ForEach(values) { item in
            let precent = item.duration / totalDuration
            
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.label)
                    Text(item.description)
                        .font(.caption)
                    Spacer()
                    Text(
                        precent,
                        format: .percent.precision(.fractionLength(2))
                    )
                }
                
                ProgressView(value: precent)
                    .tint(
                        colorScheme == .dark
                        ? item.color.opacity(TLConstant.darkColorOpacity)
                        : item.color
                    )
            }
            .frame(minHeight: 20)
            // 控制 padding
            .padding(
                .init(
                    top: 5,
                    leading: 5,
                    bottom: 5,
                    trailing: 5
                )
            )
            .listRowSeparator(.hidden)
        }
    }
}

extension LineChart {
    public struct Value: Identifiable, Equatable {
        public let label: String
        public let count: Int
        public let duration: Double
        public let color: Color
        public let id: String
        
        public init(
            id: String,
            label: String,
            count: Int,
            duration: Double,
            color: Color
        ) {
            self.id = id
            self.label = label
            self.count = count
            self.duration = duration
            self.color = color
        }
        
        public var description: String {
            "\(count)次 \(duration.formatInterval())"
        }
    }
}

#Preview {
    struct Playground: View {
        var body: some View {
            List {
                Section {
                    LineChart(
                        values: .init(uniqueElements: [
                            .init(
                                id: UUID().uuidString,
                                label: "未记录",
                                count: 1,
                                duration: 50,
                                color: .red
                            ),
                            .init(
                                id: UUID().uuidString,
                                label: "剩余时间",
                                count: 1,
                                duration: 100,
                                color: .blue
                            ),
                            .init(
                                id: UUID().uuidString,
                                label: "Task001",
                                count: 1,
                                duration: 500,
                                color: .green
                            )
                        ])
                    )
                }
            }
            
        }
    }
    
    return Playground()
}
