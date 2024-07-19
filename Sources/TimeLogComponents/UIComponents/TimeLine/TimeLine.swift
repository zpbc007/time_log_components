//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import SwiftUI

public struct TimeLine: View {
    public struct State: Equatable, Identifiable {
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
    let state: State
    
    public init(_ state: State) {
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
            VDashedLine.WithTime(
                startTime: state.startTime,
                endTime: state.showEndTime ? state.endTime : nil
            )
            
            TimeLineCard(
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
    struct TimeLineCard<TagView: View>: View {
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
