//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/22.
//

import SwiftUI
import IdentifiedCollections

public struct AnalyzeDayPage: View {
    let type: OverviewDescription.DurationType
    let reviewComment: String
    let emojiActiveColor: Color
    let totalTime: Int
    let recordDuration: TimeInterval
    let blackHoleDuration: TimeInterval
    let pipeChartValues: PipeChart.Values?
    let lineChartValues: IdentifiedArrayOf<LineChart.Value>?
    @Binding var dayStatus: DayStatus?
    let onReviewCommentTapped: () -> Void
    
    public init(
        type: OverviewDescription.DurationType,
        reviewComment: String,
        emojiActiveColor: Color,
        totalTime: Int,
        recordDuration: TimeInterval,
        blackHoleDuration: TimeInterval,
        pipeChartValues: PipeChart.Values?,
        lineChartValues: IdentifiedArrayOf<LineChart.Value>?,
        dayStatus: Binding<DayStatus?>,
        onReviewCommentTapped: @escaping () -> Void
    ) {
        self.type = type
        self.reviewComment = reviewComment
        self.emojiActiveColor = emojiActiveColor
        self.totalTime = totalTime
        self.recordDuration = recordDuration
        self.blackHoleDuration = blackHoleDuration
        self.pipeChartValues = pipeChartValues
        self.lineChartValues = lineChartValues
        self._dayStatus = dayStatus
        self.onReviewCommentTapped = onReviewCommentTapped
    }
    
    public var body: some View {
        List {
            Section {
                VStack {
                    OverviewDescription(
                        type: type,
                        totalTime: totalTime,
                        recordDuration: recordDuration,
                        blackHoleDuration: blackHoleDuration
                    )
                }
            }
            
            Section("今天过的怎么样？") {
                EmojiPicker(
                    activeColor: emojiActiveColor,
                    items: Self.DayStatusEmoji,
                    value: .init(
                        get: {
                            dayStatus?.rawValue
                        },
                        set: { newValue in
                            guard let newValue else {
                                dayStatus = nil
                                return
                            }
                            dayStatus = .init(rawValue: newValue)
                        }
                    )
                )
            }
            
            Section("每日回顾") {
                if reviewComment.isEmpty {
                    HStack {
                        Spacer()
                        Image(systemName: "square.and.pencil")
                        Text("回顾今日美好瞬间")
                        Spacer()
                    }
                    
                } else {
                    RichTextViewer(content: reviewComment, placeholder: "今日美好瞬间")
                }
            }.onTapGesture(perform: onReviewCommentTapped)
            
            Section("人生时间") {
                if let pipeChartValues {
                    PipeChart(values: pipeChartValues)
                } else {
                    HStack {
                        Spacer()
                        Text("暂无数据，快去记录吧")
                            .font(.caption)
                        Spacer()
                    }
                }
            }
            
            if let lineChartValues {
                Section("明细") {
                    LineChart(values: lineChartValues)
                }
            }
        }
    }
}

extension AnalyzeDayPage {
    public enum DayStatus: String {
        case substantial
        case normal
        case meaningless
    }
    
    static let DayStatusEmoji: [EmojiPicker.Value] = [
        .init(
            code: "😟",
            text: "空虚",
            value: DayStatus.meaningless.rawValue
        ),
        .init(
            code: "😑",
            text: "一般",
            value: DayStatus.normal.rawValue
        ),
        .init(
            code: "😄",
            text: "充实",
            value: DayStatus.substantial.rawValue
        )
    ]
}

#Preview {
    struct Playground: View {
        @State private var dayStatus: AnalyzeDayPage.DayStatus? = nil
        
        var body: some View {
            AnalyzeDayPage(
                type: .day,
                reviewComment: "{\"ops\":[{\"insert\":\"完成今日目标的开发\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"给菲打个视频\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"}]}",
                emojiActiveColor: .red,
                totalTime: 10,
                recordDuration: 2680200,
                blackHoleDuration: 2680200,
                pipeChartValues: .init(.init(uniqueElements: [
                    .init(duration: 36000 , label: "生存", color: .init(hexString: "#FDE7BBFF")),
                    .init(duration: 28800, label: "工作", color: .init(hexString: "#81BFDAFF")),
                    .init(duration: 14400, label: "自由", color: .init(hexString: "#9EDF9CFF"))
                ])),
                lineChartValues: .init(
                    uniqueElements: [
                        .init(label: "自由", count: 1, duration: 500, color: .init(hexString: "#9EDF9CFF")),
                        .init(label: "工作", count: 1, duration: 100, color: .init(hexString: "#81BFDAFF")),
                        .init(label: "生存", count: 1, duration: 50, color: .init(hexString: "#FDE7BBFF"))
                    ]
                ),
                dayStatus: $dayStatus
            ) {
                print("tap review comment")
            }
        }
    }
    
    return Playground()
}

#Preview("Empty") {
    AnalyzeDayPage(
        type: .day,
        reviewComment: "",
        emojiActiveColor: .blue,
        totalTime: 10,
        recordDuration: 2680200,
        blackHoleDuration: 2680200,
        pipeChartValues: nil,
        lineChartValues: nil,
        dayStatus: .constant(.meaningless)
    ) {
        print("tap review comment")
    }
}
