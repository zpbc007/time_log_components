//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/11/4.
//

import SwiftUI

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
    struct CardWithTag: View {
        static let durationFormatter: DateComponentsFormatter = {
            var formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.allowedUnits = [.day, .hour, .minute, .second]

            return formatter
        }()
        
        let state: CardState
        private let durationString: String?
        
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
        
        var body: some View {
            TimeLine.Card(
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

#Preview("Card") {
    TimeLine.Card(title: "事件名称", color: .green) {
        Text("tag")
    }.padding()
}

#Preview("CardWithTag") {
    List{
        TimeLine.CardWithTag(.init(
            id: UUID().uuidString,
            startTime: .now.addingTimeInterval(-600),
            endTime: .now.addingTimeInterval(-180),
            title: "超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title超长Title",
            color: .yellow
        )).listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        
        TimeLine.CardWithTag(.init(
            id: UUID().uuidString,
            startTime: .now.addingTimeInterval(-600),
            endTime: .now.addingTimeInterval(-180),
            title: "正常title",
            color: .yellow
        ))
        
        TimeLine.CardWithTag(.init(
            id: UUID().uuidString,
            startTime: .now,
            title: "正常title",
            color: .yellow
        ))
    }.listStyle(.plain)
}
