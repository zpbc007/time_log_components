//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import SwiftUI

public struct TimeLine: View {
    static let TimeWidth: CGFloat = 50
    
    public struct CardState: Equatable, Identifiable {
        public let id: String
        public let startTime: Date
        public let endTime: Date?
        public let title: String
        public let color: Color
        public let comment: String?
        public let showEndTime: Bool
        
        public init(
            id: String,
            startTime: Date,
            endTime: Date? = nil,
            title: String,
            color: Color,
            comment: String? = nil,
            showEndTime: Bool = true
        ) {
            self.id = id
            self.startTime = startTime
            self.endTime = endTime
            self.title = title
            self.color = color
            self.comment = comment
            self.showEndTime = showEndTime
        }
    }

    static let durationFormatter: DateComponentsFormatter = {
        var formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute, .second]

        return formatter
    }()
    
    private let durationString: String?
    let state: CardState
    
    public init(_ state: CardState) {
        self.state = state
        
        if let endTime = state.endTime {
            self.durationString = Self.durationFormatter.string(
                from: endTime.timeIntervalSince(state.startTime)
            ) ?? nil
        } else {
            self.durationString = nil
        }
    }
    
    public var body: some View {
        HStack {
            TLLine.WithTime(
                startTime: state.startTime,
                endTime: state.showEndTime ? state.endTime : nil
            )
            
            Card(
                title: state.title,
                color: state.color
            ) {
                Group {
                    if let durationString {
                        Label(durationString, systemImage: "clock.badge.checkmark")
                    } else {
                        Label(
                            title: {
                                Text(
                                    timerInterval: state.startTime...Date(
                                        timeInterval: 60 * 60 * 24 * 30,
                                        since: .now
                                    ),
                                    countsDown: false
                                )
                                .bold()
                            },
                            icon: {
                                Image(systemName: "clock")
                            }
                        )
                    }
                }
                .labelStyle(.roundedCornerTag)
                .font(.caption)
            }
        }
    }
}

extension TimeLine {
    struct Card<TagView: View>: View {
        let title: String
        let color: Color
        let tagView: () -> TagView
        
        init(
            title: String,
            color: Color,
            @ViewBuilder tagView: @escaping () -> TagView
        ) {
            self.title = title
            self.color = color
            self.tagView = tagView
        }
        
        var body: some View {
            HStack {
                Text(title)
                    .padding(.vertical)
                    .padding(.leading)
                
                Spacer()
                
                tagView()
                    .padding(.trailing, 5)
            }
            .padding(.leading, 5)
            .overlay(content: {
                HStack {
                    Rectangle()
                        .fill(color)
                        .frame(width: 5)
                    Spacer()
                }
            })
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}

extension TimeLine {
    struct GridBG: View {
        let oneHourHeight: CGFloat
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(0..<24, id: \.self) { hour in
                    HourView(hour: hour)
                }
            }
        }
        
        @ViewBuilder
        private func HourView(hour: Int) -> some View {
            HStack(alignment: .top, spacing: 0) {
                Text(String(format: "%02d:00", hour))
                    .frame(width: TimeLine.TimeWidth)
                    .offset(CGSize(width: 0, height: -10.0))
                
                TLLine.Vertical()
                
                TLLine.Horizental()
            }
            .frame(height: oneHourHeight)
            .foregroundStyle(.gray)
        }
    }
}

extension TimeLine {
    struct Active: View {
        let oneHourHeight: CGFloat
        
        private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        @State private var now: Date = .now
        
        var body: some View {
            ActiveDumpView(oneHourHeight: oneHourHeight, now: now)
            .onReceive(timer, perform: { newDate in
                now = newDate
            })
        }
    }
}

extension TimeLine {
    struct ActiveDumpView: View {
        static let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            return formatter
        }()
        
        let oneHourHeight: CGFloat
        let now: Date
        @State private var height: CGFloat = 0
        
        private var components: DateComponents {
            Calendar.current.dateComponents([.hour, .minute], from: now)
        }
        
        private var offset: CGFloat {
            let minutes = CGFloat((components.hour ?? 0) * 60 + (components.minute ?? 0))
            
            return minutes / 60 * oneHourHeight - height / 2
        }
        
        private var isNearToHour: Bool {
            let minutes = components.minute ?? 0
            
            return minutes <= 10 || minutes >= 50
        }
        
        var body: some View {
            HStack(spacing: 0) {
                Text(Self.formatter.string(from: now))
                    .padding(.vertical, isNearToHour ? 20 : 0)
                    .background(.white)
                    .frame(width: TimeLine.TimeWidth)
                    
                
                TLLine.Active()
                    .padding(.leading, 2)
            }
            .foregroundStyle(.black)
            .contentSize()
            .onPreferenceChange(SizePreferenceKey.self, perform: { value in
                height = value.height
            })
            .offset(y: offset)
        }
    }
}

extension TimeLine {
    struct GridBGWithActive: View {
        let oneHourHeight: CGFloat = 100
        
        var body: some View {
            ScrollView {
                ZStack(alignment: .top) {
                    GridBG(oneHourHeight: oneHourHeight)
                    
                    Active(oneHourHeight: oneHourHeight)
                }
            }
        }
    }
}

#Preview("GridBGWithActive") {
    TimeLine.GridBGWithActive()
}

#Preview("GridBGWithActive static") {
    ScrollView {
        ZStack(alignment: .top) {
            TimeLine.GridBG(oneHourHeight: 100)
            
            TimeLine.ActiveDumpView(oneHourHeight: 100, now: {
                Calendar.current.date(from: .init(hour: 1, minute: 8)) ?? .now
            }())
        }
    }
}

#Preview {
    List {
        TimeLine(.init(
            id: UUID().uuidString,
            startTime: .now.addingTimeInterval(-600),
            endTime: .now.addingTimeInterval(-180),
            title: "超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title",
            color: .yellow
        ))
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        
        TimeLine(.init(
            id: UUID().uuidString,
            startTime: .now.addingTimeInterval(-600),
            endTime: .now.addingTimeInterval(-180),
            title: "正常title",
            color: .yellow
        ))
        
        TimeLine(.init(
            id: UUID().uuidString,
            startTime: .now,
            title: "正常title",
            color: .yellow
        ))
    }
    .listStyle(.plain)
}
