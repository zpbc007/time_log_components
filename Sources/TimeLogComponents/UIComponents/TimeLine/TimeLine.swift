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
        public let endTime: Date
        public let title: String
        public let color: Color
        public let comment: String?
        public let showEndTime: Bool
        
        public init(
            id: String,
            startTime: Date,
            endTime: Date,
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
        
        func toTimeLineState(start: Date, end: Date) -> TimeLine.TimeLineState {
            .init(
                id: self.id,
                startMinute: start.minutesBetween(to: self.startTime < start ? start : self.startTime),
                endMinute: start.minutesBetween(to: self.endTime > end ? end : self.endTime)
            )
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
    
//    public init(_ state: CardState) {
//        self.state = state
//        
//        if let endTime = state.endTime {
//            self.durationString = Self.durationFormatter.string(
//                from: endTime.timeIntervalSince(state.startTime)
//            ) ?? nil
//        } else {
//            self.durationString = nil
//        }
//    }
    
    public var body: some View {
        HStack {
            TLLine.WithTime(
                startTime: state.startTime,
                endTime: state.showEndTime ? state.endTime : nil
            )
            
//            Card(
//                title: state.title,
//                color: state.color,
//            ) {
//                Group {
//                    if let durationString {
//                        Label(durationString, systemImage: "clock.badge.checkmark")
//                    } else {
//                        Label(
//                            title: {
//                                Text(
//                                    timerInterval: state.startTime...Date(
//                                        timeInterval: 60 * 60 * 24 * 30,
//                                        since: .now
//                                    ),
//                                    countsDown: false
//                                )
//                                .bold()
//                            },
//                            icon: {
//                                Image(systemName: "clock")
//                            }
//                        )
//                    }
//                }
//                .labelStyle(.roundedCornerTag)
//                .font(.caption)
//            }
        }
    }
}

extension TimeLine {
    struct GridBG: View {
        static let FullHeightCoordinateSpaceName = "grid_bg_full_height"
        static let ScrollCoordinateSpaceName = "grid_bg_scroll"
        static let ContainerVerticalPadding: CGFloat = 10
        // 拖拽检测边界
        private static let DragEdgePadding: CGFloat = 40
        
        let oneMinuteHeight: CGFloat
        let scrollViewHeight: CGFloat
        let scrollOffset: CGFloat
        let absScrollOffset: CGFloat
        let maxAbsScrollOffset: CGFloat
        let scrollViewProxy: ScrollViewProxy?
        let selectAction: (_ startHour: Int, _ startMinute: Int, _ endHour: Int, _ endMinute: Int) -> Void
        @GestureState private var dragState = DragState.inactive
        
        private let oneHourHeight: CGFloat
        private let oneDayHeight: CGFloat
        private let stepHeight: CGFloat
        
        init(
            oneMinuteHeight: CGFloat,
            scrollViewHeight: CGFloat,
            scrollOffset: CGFloat,
            scrollViewProxy: ScrollViewProxy? = nil,
            selectAction: @escaping (_ startHour: Int, _ startMinute: Int, _ endHour: Int, _ endMinute: Int) -> Void
        ) {
            self.oneMinuteHeight = oneMinuteHeight
            self.scrollViewHeight = scrollViewHeight
            self.scrollOffset = scrollOffset
            self.scrollViewProxy = scrollViewProxy
            self.selectAction = selectAction
            
            let oneHourHeight = oneMinuteHeight * 60
            let oneDayHeight = oneHourHeight * 24
            
            self.absScrollOffset = abs(scrollOffset)
            self.maxAbsScrollOffset = oneDayHeight - scrollViewHeight
            self.oneHourHeight = oneHourHeight
            self.oneDayHeight = oneDayHeight
            // 最少间隔 5 min
            self.stepHeight = oneMinuteHeight * 5
        }
        
        var body: some View {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HourView(hour: hour)
                            .id(hour)
                    }
                }.coordinateSpace(name: Self.FullHeightCoordinateSpaceName)
                
                HStack {
                    Spacer(minLength: TimeLine.TimeWidth)
                    
                    Color.blue.opacity(0.3)
                        .frame(height: dragState.dragRectInfo.height)
                        .offset(y: dragState.dragRectInfo.offsetY)
                }
            }.onChange(of: dragState) { _, newValue in
                updateScrollViewPos()
            }
        }
        
        private func updateScrollViewPos() {
            guard let dragInfo = dragState.dragInfo else {
                return
            }
            
            if dragState.dragDirection == .up {
                let dragTopEdge = dragInfo.endY - Self.DragEdgePadding
                // 到达上边界 向上移动 1 小时
                if dragTopEdge < absScrollOffset && absScrollOffset != 0 {
                    let nextTopId = Int(floor((absScrollOffset - oneHourHeight) / oneHourHeight))
                    
                    withAnimation {
                        scrollViewProxy?.scrollTo(
                            max(0, nextTopId)
                        )
                    }
                }
            } else {
                let dragBottomEdge = dragInfo.endY + Self.DragEdgePadding
                let bottomEdge = absScrollOffset + scrollViewHeight - Self.ContainerVerticalPadding * 2
                // 到达下边界，向下移动 1 小时
                if dragBottomEdge > bottomEdge 
                    && abs(absScrollOffset - maxAbsScrollOffset) > 5 // maxAbsScrollOffset 有小数部分
                {
                    let nextBottomId = Int(ceil(absScrollOffset + oneHourHeight + scrollViewHeight) / oneHourHeight)
                    
                    withAnimation {
                        scrollViewProxy?.scrollTo(
                            min(23, nextBottomId)
                        )
                    }
                }
            }
        }
        
        private var gesture: some Gesture {
            LongPressGesture(minimumDuration: 0.3)
                .sequenced(before: DragGesture(
                    minimumDistance: 0,
                    coordinateSpace: .named(Self.FullHeightCoordinateSpaceName)
                ))
                .updating($dragState) { value, state, transaction in
                    switch value {
                    case .first:
                        state = .pressing
                    case .second(_, let dragState):
                        guard let dragState else {
                            state = .dragging(startY: nil, endY: nil)
                            return
                        }
                        let (startY, endY) = getPosFromDragState(dragState: dragState)
                        
                        state = .dragging(
                            startY: startY,
                            endY: endY
                        )
                    }
                }
                .onEnded { value in
                    switch value {
                    case .second(_, let dragState):
                        guard let dragState else {
                            return
                        }
                        let (startY, endY) = getPosFromDragState(dragState: dragState)
                        let newState: DragState = .dragging(startY: startY, endY: endY)
                        
                        let (offsetY, height) = newState.dragRectInfo
                        if height == 0 {
                            return
                        }
                        
                        let startAllMinute = Int(floor(offsetY / oneMinuteHeight))
                        let endAllMinute = Int(floor((offsetY + height) / oneMinuteHeight))
                        
                        selectAction(
                            startAllMinute / 60, startAllMinute % 60,
                            endAllMinute / 60, endAllMinute % 60
                        )
                    default:
                        return
                    }
                }
        }
        
        private func roundPos(_ y: CGFloat) -> CGFloat {
            let pos = floor(y / stepHeight) * stepHeight
            
            // 不能超出下边界
            return min(
                oneDayHeight,
                // 不能超出上边界
                max(0, pos)
            )
        }
        
        private func getPosFromDragState(dragState: DragGesture.Value) -> (startY: CGFloat, endY: CGFloat) {
            let startY = roundPos(dragState.startLocation.y)
            var endY = roundPos(dragState.location.y)
            
            if startY == endY {
                if endY + stepHeight < oneDayHeight {
                    endY += stepHeight
                } else {
                    endY -= stepHeight
                }
            }
            
            return (startY, endY)
        }
        
        @ViewBuilder
        private func HourView(hour: Int) -> some View {
            HStack(alignment: .top, spacing: 0) {
                Text(String(format: "%02d:00", hour))
                    .frame(width: TimeLine.TimeWidth)
                    .offset(CGSize(width: 0, height: -10.0))
                
                HStack(alignment: .top, spacing: 0) {
                    TLLine.Vertical()
                    
                    TLLine.Horizental()
                }
                .contentShape(Rectangle())
                // fix: 避免 scrollView 无法滚动
                .onTapGesture {}
                .gesture(gesture)
            }
            .frame(height: oneHourHeight)
            .foregroundStyle(.gray)
        }
    }
}

extension TimeLine.GridBG {
    enum DragState: Equatable {
        enum Direction {
            case up
            case down
        }
        case inactive
        case pressing
        case dragging(startY: CGFloat?, endY: CGFloat?)
        
        var dragRectInfo: (offsetY: CGFloat, height: CGFloat) {
            switch self {
            case .dragging(startY: let startY, endY: let endY):
                guard let startY, let endY else {
                    return (0, 0)
                }
                
                return (min(startY, endY), abs(startY - endY))
            default:
                return (0, 0)
            }
        }
        
        var dragDirection: Direction {
            switch self {
            case .dragging(startY: let startY, endY: let endY):
                guard let startY, let endY else {
                    return .up
                }
                
                return endY > startY ? .down : .up
            default:
                return .up
            }
        }
        
        var dragInfo: (startY: CGFloat, endY: CGFloat)? {
            switch self {
            case .dragging(startY: let startY, endY: let endY):
                guard let startY, let endY else {
                    return nil
                }
                
                return (startY, endY)
            default:
                return nil
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .dragging:
                return true
            default:
                return false
            }
        }
        
        var isPressing: Bool {
            switch self {
            case .inactive:
                return false
            default:
                return true
            }
        }
    }
}

extension TimeLine {
    struct Active: View {
        let oneMinuteHeight: CGFloat
        
        private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        @State private var now: Date = .now
        
        var body: some View {
            ActiveDumpView(oneMinuteHeight: oneMinuteHeight, now: now)
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
        
        let oneMinuteHeight: CGFloat
        let now: Date
        @State private var height: CGFloat = 0
        
        private var components: DateComponents {
            Calendar.current.dateComponents([.hour, .minute], from: now)
        }
        
        private var offset: CGFloat {
            let minutes = CGFloat((components.hour ?? 0) * 60 + (components.minute ?? 0))
            
            return minutes * oneMinuteHeight - height / 2
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
    struct TimeLineState: Equatable, Identifiable {
        let id: String
        let startMinute: Int
        let endMinute: Int
        
        func toAcc(_ prevMinute: Int) -> TimeLineStateWithAcc {
            .init(
                id: self.id,
                prevMinute: prevMinute,
                startMinute: self.startMinute,
                endMinute: self.endMinute
            )
        }
    }
    
    struct TimeLineStateWithAcc: Equatable, Identifiable {
        let id: String
        let prevMinute: Int
        let startMinute: Int
        let endMinute: Int
        
        var totalMinutes: CGFloat {
            CGFloat(integerLiteral: endMinute - startMinute)
        }
        
        var offsetMinutes: CGFloat {
            CGFloat(integerLiteral: startMinute - prevMinute)
        }
    }
}

extension [TimeLine.TimeLineState] {
    func toAcc() -> [TimeLine.TimeLineStateWithAcc] {
        self.reduce(into: .init()) { partialResult, item in
            guard let last = partialResult.last else {
                partialResult.append(item.toAcc(0))
                return
            }
            
            partialResult.append(
                item.toAcc(last.prevMinute + last.endMinute - last.startMinute)
            )
        }
    }
}

extension TimeLine {
    struct GridBGWithActive<Content: View, Header: View>: View {
        let oneMinuteHeight: CGFloat
        let items: [TimeLine.TimeLineStateWithAcc]
        let latestHour: Int?
        let disableTransition: Bool
        let header: () -> Header
        let content: (_ id: TimeLine.TimeLineStateWithAcc.ID, _ height: CGFloat) -> Content
        let selectAction: (_ startHour: Int, _ startMinute: Int, _ endHour: Int, _ endMinute: Int) -> Void
        
        @State private var scrollOffset: CGFloat = 0
        @State private var scrollViewHeight: CGFloat = 0
        
        init(
            oneMinuteHeight: CGFloat = 3,
            items: [TimeLine.TimeLineState],
            latestHour: Int? = nil,
            disableTransition: Bool = false,
            @ViewBuilder header: @escaping () -> Header,
            @ViewBuilder content: @escaping (_ id: TimeLine.TimeLineStateWithAcc.ID, _ height: CGFloat) -> Content,
            selectAction: @escaping (_ startHour: Int, _ startMinute: Int, _ endHour: Int, _ endMinute: Int) -> Void
        ) {
            self.oneMinuteHeight = oneMinuteHeight
            self.items = items.toAcc()
            self.latestHour = latestHour
            self.disableTransition = disableTransition
            self.header = header
            self.content = content
            self.selectAction = selectAction
        }
        
        var body: some View {
            ScrollViewReader(content: { proxy in
                ScrollView {
                    header()
                    
                    ZStack(alignment: .top) {
                        GridBG(
                            oneMinuteHeight: oneMinuteHeight,
                            scrollViewHeight: scrollViewHeight,
                            scrollOffset: scrollOffset,
                            scrollViewProxy: proxy,
                            selectAction: selectAction
                        )
                        
                        Active(oneMinuteHeight: oneMinuteHeight)
                        
                        self.TimeLineContent
                    }.scrollOffset(
                        coordinateSpace: .named(TimeLine.GridBG.ScrollCoordinateSpaceName)
                    ).padding(.vertical, TimeLine.GridBG.ContainerVerticalPadding)
                }
                .coordinateSpace(name: TimeLine.GridBG.ScrollCoordinateSpaceName)
                .onPreferenceChange(
                    ScrollOffsetPreferenceKey.self,
                    perform: { value in
                        scrollOffset = value
                    }
                ).onChange(of: latestHour) { _, newValue in
                    guard let newValue else {
                        return
                    }
                    withAnimation {
                        proxy.scrollTo(newValue)
                    }
                }
            })
            .contentSize()
            .onPreferenceChange(SizePreferenceKey.self, perform: { value in
                scrollViewHeight = value.height
            })
        }
        
        @ViewBuilder
        private var TimeLineContent: some View {
            HStack(alignment: .top, spacing: 0) {
                HStack {}
                    .frame(width: TimeLine.TimeWidth)
                
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        content(item.id, item.totalMinutes * oneMinuteHeight)
                            .offset(y: item.offsetMinutes * oneMinuteHeight)
                            .transition(
                                disableTransition
                                    ? .identity
                                    : .asymmetric(
                                        insertion: .move(edge: .trailing)
                                            .combined(
                                                with: .scale(scale: 0.1).animation(.bouncy)
                                            ),
                                        removal: .opacity
                                    )
                            )
                    }
                }
            }
        }
    }
}

#Preview("GridBGWithActive") {
    struct Playground: View {
        @State var latestHour: Int? = nil
        let items: [TimeLine.TimeLineState] = [
            .init(id: UUID().uuidString, startMinute: 0, endMinute: 30),
            .init(id: UUID().uuidString, startMinute: 35, endMinute: 40),
            .init(id: UUID().uuidString, startMinute: 60, endMinute: 120)
        ]
        
        var body: some View {
            VStack {
                HStack {
                    Text("top")
                        .frame(height: 100)
                    Spacer()
                    Button("scroll to 21:00") {
                        latestHour = 21
                    }
                    Button("scroll to 00:00") {
                        latestHour = 0
                    }
                }.padding(.horizontal)
                
                
                TimeLine.GridBGWithActive(
                    oneMinuteHeight: 5,
                    items: items,
                    latestHour: latestHour
                ) {
                    Text("Header")
                } content: { (id, height) in
                    HStack {
                        Text("id: \(id)")
                        
                        Spacer()
                    }
                    .frame(height: height)
                    .background(.green.opacity(0.4))
                    .onTapGesture {
                        print("tap id: \(id)")
                    }
                } selectAction: { startHour, startMinute, endHour, endMinute in
                    print("select: start: \(startHour):\(startMinute), end: \(endHour):\(endMinute)")
                }
                
                Text("bottom")
                    .frame(height: 100)
            }
        }
    }
    
    return Playground()
}
