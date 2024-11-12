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
        let height: CGFloat?
        let fontValue: Font?
        let tagView: () -> TagView
        
        init(
            title: String,
            color: Color,
            height: CGFloat? = nil,
            fontValue: Font? = nil,
            @ViewBuilder tagView: @escaping () -> TagView
        ) {
            self.title = title
            self.color = color
            self.height = height
            self.fontValue = fontValue
            self.tagView = tagView
        }
        
        var body: some View {
            HStack {
                Text(title)
                    .font(fontValue)
                    .padding(.leading, 5)
                
                Spacer()
                
                tagView()
                    .opacity(0.8)
                    .padding(.trailing, 5)
            }
            .padding(.leading, 5)
            .frame(height: height)
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
        let height: CGFloat?
        let fontValue: Font
        let tagFontValue: Font
        private let durationString: String
        
        public init(
            _ state: CardState,
            height: CGFloat? = nil
        ) {
            self.state = state
            self.height = height
            
            if let height {
                self.fontValue = Self.getFontFromHeight(height)
                self.tagFontValue = Self.getTagFontFromHeight(height)
            } else {
                self.fontValue = .body
                self.tagFontValue = .caption
            }
            
            self.durationString = Self.durationFormatter.string(
                from: state.endTime.timeIntervalSince(state.startTime)
            ) ?? ""
        }
        
        var body: some View {
            TimeLine.Card(
                title: state.title,
                color: state.color,
                height: height,
                fontValue: fontValue
            ) {
                Label(durationString, systemImage: "clock.badge.checkmark")
                    .font(tagFontValue)
                    .labelStyle(.roundedCornerTag)
            }
        }
    }
}

extension TimeLine.CardWithTag {
    static func getFontFromHeight(_ height: CGFloat) -> Font {
        if height <= 6 {
            return .system(size: 6)
        } else if height <= 10 {
            return .system(size: 7)
        } else if height <= 15 {
            return .system(size: 9)
        } else if height <= 30 {
            return .caption2
        } else if height <= 40 {
            return .caption
        } else if height <= 50 {
            return .footnote
        } else {
            return .body
        }
    }
    
    static func getTagFontFromHeight(_ height: CGFloat) -> Font {
        if height <= 6 {
            return .system(size: 6)
        } else if height <= 10 {
            return .system(size: 7)
        } else if height <= 15 {
            return .system(size: 9)
        } else if height <= 30 {
            return .caption2
        } else {
            return .caption
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
            title: "默认值",
            color: .yellow
        ))
        
        TimeLine.CardWithTag(.init(
            id: UUID().uuidString,
            startTime: .now,
            endTime: .now,
            title: "height 6 高度中文",
            color: .yellow
        ), height: 6)
        
        TimeLine.CardWithTag(.init(
            id: UUID().uuidString,
            startTime: .now,
            endTime: .now,
            title: "height 7 高度中文",
            color: .yellow
        ), height: 7)
        
        TimeLine.CardWithTag(.init(
            id: UUID().uuidString,
            startTime: .now,
            endTime: .now,
            title: "height 11 高度中文",
            color: .yellow
        ), height: 11)
        
        TimeLine.CardWithTag(.init(
            id: UUID().uuidString,
            startTime: .now,
            endTime: .now,
            title: "height 31 高度中文",
            color: .yellow
        ), height: 31)
        
        TimeLine.CardWithTag(.init(
            id: UUID().uuidString,
            startTime: .now,
            endTime: .now,
            title: "height 41 高度中文",
            color: .yellow
        ), height: 41)
        
        TimeLine.CardWithTag(.init(
            id: UUID().uuidString,
            startTime: .now,
            endTime: .now,
            title: "height 51 高度中文",
            color: .yellow
        ), height: 51)
    }.listStyle(.plain)
}
