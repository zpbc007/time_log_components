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
    let todayTargetComment: String
    let todayTargets: [AnalyzeDayPage.Target]
    let tomorrowTargetComment: String
    let tomorrowTargets: [AnalyzeDayPage.Target]
    let emojiActiveColor: Color
    let totalTime: Int
    let recordDuration: TimeInterval
    let blackHoleDuration: TimeInterval
    let pipeChartValues: PipeChart.Values?
    let lineChartValues: IdentifiedArrayOf<LineChart.Value>?
    @Binding var dayStatus: DayStatus?
    
    let tapReviewCommentAction: () -> Void
    
    let tapTodayCommentAction: () -> Void
    let addTodayTargetAction: () -> Void
    let tapTodayTargetAction: (AnalyzeDayPage.Target) -> Void
    let todayTargetsDeleteAction: (IndexSet) -> Void

    let tapTomorrowCommentAction: () -> Void
    let addTomorrowTargetAction: () -> Void
    let tapTomorrowTargetAction: (AnalyzeDayPage.Target) -> Void
    let tomorrowTargetsDeleteAction: (IndexSet) -> Void
    let lifetimeAISuggestionTapAction: () -> Void
        
    public init(
        type: OverviewDescription.DurationType,
        reviewComment: String,
        todayTargetComment: String,
        todayTargets: [AnalyzeDayPage.Target],
        tomorrowTargetComment: String,
        tomorrowTargets: [AnalyzeDayPage.Target],
        emojiActiveColor: Color,
        totalTime: Int,
        recordDuration: TimeInterval,
        blackHoleDuration: TimeInterval,
        pipeChartValues: PipeChart.Values?,
        lineChartValues: IdentifiedArrayOf<LineChart.Value>?,
        dayStatus: Binding<DayStatus?>,
        tapReviewCommentAction: @escaping () -> Void,
        tapTodayCommentAction: @escaping () -> Void,
        addTodayTargetAction: @escaping () -> Void,
        tapTodayTargetAction: @escaping (AnalyzeDayPage.Target) -> Void,
        todayTargetsDeleteAction: @escaping (IndexSet) -> Void,
        tapTomorrowCommentAction: @escaping () -> Void,
        addTomorrowTargetAction: @escaping () -> Void,
        tapTomorrowTargetAction: @escaping (AnalyzeDayPage.Target) -> Void,
        tomorrowTargetsDeleteAction: @escaping (IndexSet) -> Void,
        lifetimeAISuggestionTapAction: @escaping () -> Void
    ) {
        self.type = type
        self.reviewComment = reviewComment
        self.todayTargetComment = todayTargetComment
        self.todayTargets = todayTargets
        self.tomorrowTargetComment = tomorrowTargetComment
        self.tomorrowTargets = tomorrowTargets
        self.emojiActiveColor = emojiActiveColor
        self.totalTime = totalTime
        self.recordDuration = recordDuration
        self.blackHoleDuration = blackHoleDuration
        self.pipeChartValues = pipeChartValues
        self.lineChartValues = lineChartValues
        self._dayStatus = dayStatus
        
        self.tapReviewCommentAction = tapReviewCommentAction
        
        self.tapTodayCommentAction = tapTodayCommentAction
        self.addTodayTargetAction = addTodayTargetAction
        self.tapTodayTargetAction = tapTodayTargetAction
        self.todayTargetsDeleteAction = todayTargetsDeleteAction
        
        self.tapTomorrowCommentAction = tapTomorrowCommentAction
        self.addTomorrowTargetAction = addTomorrowTargetAction
        self.tapTomorrowTargetAction = tapTomorrowTargetAction
        self.tomorrowTargetsDeleteAction = tomorrowTargetsDeleteAction
        self.lifetimeAISuggestionTapAction = lifetimeAISuggestionTapAction
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
            
            self.buildTargetSection(
                title: "今日目标",
                comment: todayTargetComment,
                targets: todayTargets,
                tapCommentAction: tapTodayCommentAction,
                addTargetAction: addTodayTargetAction,
                tapTargetAction: tapTodayTargetAction,
                deleteTargetAction: todayTargetsDeleteAction
            )

            self.buildTextViewer(
                title: "每日回顾",
                text: reviewComment,
                placeholder: "回顾今日美好瞬间",
                onTapAction: tapReviewCommentAction
            )
            
            self.buildTargetSection(
                title: "明日目标",
                comment: tomorrowTargetComment,
                targets: tomorrowTargets,
                tapCommentAction: tapTomorrowCommentAction,
                addTargetAction: addTomorrowTargetAction,
                tapTargetAction: tapTomorrowTargetAction,
                deleteTargetAction: tomorrowTargetsDeleteAction
            )
            
            Section {
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
            } header: {
                HStack {
                    Text("人生时间")
                    
                    Spacer()
                    
                    if pipeChartValues != nil {
                        Button(action: lifetimeAISuggestionTapAction) {
                            HStack {
                                Image(systemName: "lightbulb.max")
                                Text("AI 分析")
                            }
                        }
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
    
    @ViewBuilder
    private func buildTextViewer(
        title: String,
        text: String,
        placeholder: String,
        onTapAction: @escaping () -> Void
    ) -> some View {
        Section(title) {
            if text.isEmpty || text == RichTextViewer.emptyOps {
                HStack {
                    Spacer()
                    Image(systemName: "square.and.pencil")
                    Text(placeholder)
                    Spacer()
                }
            } else {
                RichTextViewer(content: text, placeholder: placeholder)
            }
        }.onTapGesture(perform: onTapAction)
    }
    
    @ViewBuilder
    private func buildTarget(_ target: AnalyzeDayPage.Target) -> some View {
        if let config = target.config {
            HStack {
                Text(target.name)
                Spacer()
                Text("\(config.time)次 \(config.duration.formatInterval())")
                    .font(.caption)
            }.padding(.horizontal)
        } else {
            Text(target.name)
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func buildTargetSection(
        title: String,
        comment: String,
        targets: [AnalyzeDayPage.Target],
        tapCommentAction: @escaping () -> Void,
        addTargetAction: @escaping () -> Void,
        tapTargetAction: @escaping (AnalyzeDayPage.Target) -> Void,
        deleteTargetAction: @escaping (IndexSet) -> Void
    ) -> some View {
        Section {
            if (
                comment.isEmpty
                || comment == RichTextViewer.emptyOps
            ) && targets.isEmpty
            {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                    Text("设定今日目标")
                    Spacer()
                }.onTapGesture(perform: addTargetAction)
            }
            
            if !targets.isEmpty {
                ForEach(targets) { target in
                    buildTarget(target)
                        .onTapGesture(perform: {
                            tapTargetAction(target)
                        })
                }.onDelete(perform: deleteTargetAction)
            }
            
            if !comment.isEmpty
                && comment != RichTextViewer.emptyOps
            {
                RichTextViewer(
                    content: comment,
                    placeholder: title
                ).onTapGesture(perform: tapCommentAction)
            }
        } header: {
            HStack {
                Text(title)
                
                Spacer()
                
                Button(
                    action: tapCommentAction,
                    label: {
                        Image(systemName: "bubble")
                    }
                )
                
                Button(
                    action: addTargetAction,
                    label: {
                        Image(systemName: "plus")
                    }
                )
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

extension AnalyzeDayPage {
    public struct Target: Identifiable, Equatable {
        public struct Config: Equatable {
            public var time: Int
            public var duration: Double
            
            public init(time: Int, duration: Double) {
                self.time = time
                self.duration = duration
            }
        }
        
        public let id: String
        public let name: String
        public var config: Config?
        
        public init(
            id: String,
            name: String,
            config: Config? = nil
        ) {
            self.id = id
            self.name = name
            self.config = config
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var dayStatus: AnalyzeDayPage.DayStatus? = nil
        @State private var todayTargets: [AnalyzeDayPage.Target] = [
            .init(
                id: UUID().uuidString,
                name: "today-event1",
                config: .init(time: 5, duration: 60 * 60 * 2.0)
            ),
            .init(
                id: UUID().uuidString,
                name: "today-event2",
                config: .init(
                    time: 5,
                    duration: 60 * 60 * 2.0
                )
                
            ),
            .init(
                id: UUID().uuidString,
                name: "today-event3",
                config: .init(
                    time: 5,
                    duration: 60 * 60 * 2.0
                )
            )
        ]
        @State private var tomorrowTargets: [AnalyzeDayPage.Target] = [
            .init(
                id: UUID().uuidString,
                name: "tomorrow-event1"
            ),
            .init(
                id: UUID().uuidString,
                name: "tomorrow-event2"
            )
        ]
        
        var body: some View {
            AnalyzeDayPage(
                type: .day,
                reviewComment: "{\"ops\":[{\"insert\":\"完成今日目标的开发\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"给菲打个视频\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"}]}",
                todayTargetComment: "{\"ops\":[{\"insert\":\"完成今日目标的开发\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"给菲打个视频\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"}]}",
                todayTargets: todayTargets,
                tomorrowTargetComment: "{\"ops\":[{\"insert\":\"完成今日目标的开发\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"给菲打个视频\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"},{\"insert\":\"保持开心\"},{\"attributes\":{\"list\":\"unchecked\"},\"insert\":\"\\n\"}]}",
                tomorrowTargets: tomorrowTargets,
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
                        .init(
                            id: UUID().uuidString,
                            label: "自由",
                            count: 1,
                            duration: 500,
                            color: .init(hexString: "#9EDF9CFF")
                        ),
                        .init(
                            id: UUID().uuidString,
                            label: "工作",
                            count: 1,
                            duration: 100,
                            color: .init(hexString: "#81BFDAFF")
                        ),
                        .init(
                            id: UUID().uuidString,
                            label: "生存",
                            count: 1,
                            duration: 50,
                            color: .init(hexString: "#FDE7BBFF")
                        )
                    ]
                ),
                dayStatus: $dayStatus
            ) {
                print("tapReviewCommentAction")
            } tapTodayCommentAction: {
                print("tapTodayCommentAction")
            } addTodayTargetAction: {
                print("addTodayTargetAction")
                todayTargets.append(.init(
                    id: UUID().uuidString,
                    name: "today-event-\(todayTargets.count)",
                    config: .init(
                        time: 5,
                        duration: 1.5 * 60 * 60
                    )
                ))
            } tapTodayTargetAction: { target in
                print("tapTodayTargetAction: \(target.name)")
                todayTargets = todayTargets.map({ oldTarget in
                    if oldTarget == target {
                        return .init(
                            id: oldTarget.id,
                            name: "\(oldTarget.name)-new",
                            config: oldTarget.config
                        )
                    } else {
                        return oldTarget
                    }
                })
            } todayTargetsDeleteAction: { offsets in
                print("todayTargetsDeleteAction")
                todayTargets.remove(atOffsets: offsets)
            } tapTomorrowCommentAction: {
                print("tapTomorrowCommentAction")
            } addTomorrowTargetAction: {
                print("addTomorrowTargetAction")
                tomorrowTargets.append(.init(
                    id: UUID().uuidString,
                    name: "tomorrow-event-\(tomorrowTargets.count)"
                ))
            } tapTomorrowTargetAction: { target in
                print("tapTomorrowTargetAction")
                tomorrowTargets = tomorrowTargets.map({ oldTarget in
                    if oldTarget == target {
                        return .init(
                            id: oldTarget.id,
                            name: "\(oldTarget.name)-new",
                            config: oldTarget.config
                        )
                    } else {
                        return oldTarget
                    }
                })
            } tomorrowTargetsDeleteAction: { offsets in
                print("tomorrowTargetsDeleteAction")
                tomorrowTargets.remove(atOffsets: offsets)
            } lifetimeAISuggestionTapAction: {
                print("lifetimeAISuggestionTapAction")
            }
        }
    }
    
    return Playground()
}

#Preview("Empty") {
    AnalyzeDayPage(
        type: .day,
        reviewComment: "",
        todayTargetComment: "",
        todayTargets: [],
        tomorrowTargetComment: "",
        tomorrowTargets: [],
        emojiActiveColor: .blue,
        totalTime: 10,
        recordDuration: 2680200,
        blackHoleDuration: 2680200,
        pipeChartValues: nil,
        lineChartValues: nil,
        dayStatus: .constant(.meaningless)
    ) {
        print("tapReviewCommentAction")
    } tapTodayCommentAction: {
        print("tapTodayCommentAction")
    } addTodayTargetAction: {
        print("addTodayTargetAction")
    } tapTodayTargetAction: { target in
        print("tapTodayTargetAction \(target.name)")
    } todayTargetsDeleteAction: { _ in
        print("todayTargetsDeleteAction")
    } tapTomorrowCommentAction: {
        print("tap tomorrow target")
    } addTomorrowTargetAction: {
        print("addTomorrowTargetAction")
    } tapTomorrowTargetAction: { target in
        print("tapTomorrowTargetAction \(target.name)")
    } tomorrowTargetsDeleteAction: { _ in
        print("tomorrowTargetsDeleteAction")
    } lifetimeAISuggestionTapAction: {
        print("lifetimeAISuggestionTapAction")
    }
}
