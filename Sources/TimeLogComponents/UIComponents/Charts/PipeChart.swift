//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/22.
//

import SwiftUI
import IdentifiedCollections
import Charts

public struct PipeChart: View {
    let values: Values
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedDuration: Double?
    @State private var selectedSector: String?
    
    public init(values: Values) {
        self.values = values
    }
    
    public var body: some View {
        Chart {
            ForEach(values.items) { item in
                buildSectorMark(item)
            }
        }
        .chartForegroundStyleScale(range: colorScheme == .dark ? values.darkColorArray : values.colorArray)
        .chartLegend(.hidden)
        .chartAngleSelection(value: .init(get: {
            selectedDuration
        }, set: { newValue in
            self.selectedDuration = newValue
            withAnimation {
                if let newValue {
                    self.selectedSector = findSelectedSector(value: newValue)
                } else {
                    self.selectedSector = nil
                }
            }
        }))
        .chartBackground { proxy in
            if let selectedSector = selectedSector, let selectedValue = values.items[id: selectedSector] {
                VStack {
                    Text(selectedValue.label)
                        .font(.title)
                    HStack {
                        Text("\(selectedValue.duration.formatInterval())")
                        
                        Text(
                            selectedValue.duration / values.totalDuration,
                            format: .percent.precision(.fractionLength(2))
                        )
                    }
                    
                }
            } else {
                VStack {
                    Text("总时长")
                        .font(.title)

                    Text(values.totalDurationString)
                }
            }
        }
        .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
    }
    
    private func findSelectedSector(value: Double) -> String? {
        var accumulatedCount: Double = 0

        let targetItem = values.items.first { item in
            accumulatedCount += item.duration
            return value <= accumulatedCount
        }

        return targetItem?.label
    }
    
    private func buildSectorMark(_ item: Value) -> some ChartContent {
        let isActiveSector = selectedSector == item.label

        return SectorMark(
            angle: .value("value", item.duration),
            innerRadius: .ratio(0.65),
            outerRadius: isActiveSector ? .ratio(1) : .ratio(0.9),
            angularInset: 2
        )
        .foregroundStyle(by: .value("label", item.label))
        .cornerRadius(10)
        .opacity(
            selectedSector == nil || isActiveSector ? 1 : 0.5
        )
    }
}

extension PipeChart {
    public struct Value: Identifiable, Equatable {
        public var duration: Double
        public var label: String
        public var color: Color
        
        public var id: String {
            label
        }
        
        public init(
            duration: Double,
            label: String,
            color: Color
        ) {
            self.duration = duration
            self.label = label
            self.color = color
        }
    }
    
    public struct Values: Equatable {
        let items: IdentifiedArrayOf<Value>
        let totalDuration: Double
        let totalDurationString: String
        let colorArray: [Color]
        let darkColorArray: [Color]
        
        public init(_ items: IdentifiedArrayOf<Value>) {
            self.items = items
            let totalDuraiton = items.reduce(0.0, { partialResult, value in
                partialResult + value.duration
            })
            self.totalDuration = totalDuraiton
            self.totalDurationString = totalDuraiton.formatInterval()
            self.colorArray = items.map({ $0.color })
            self.darkColorArray = items.map({ $0.color.opacity(TLConstant.darkColorOpacity) })
        }
    }
}

#Preview {
    struct Playground: View {
        let values: IdentifiedArrayOf<PipeChart.Value> = .init(
            uniqueElements: [
                .init(duration: 3600, label: "label 1", color: .red),
                .init(duration: 1800, label: "label 2", color: .blue),
                .init(duration: 3000, label: "label 3", color: .black)
            ]
        )
        
        var body: some View {
            PipeChart(values: .init(values))
        }
    }
    
    return Playground()
}
