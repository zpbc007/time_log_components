//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2025/1/14.
//

import SwiftUI
import IdentifiedCollections

public struct EventList: View {
    let events: [EventSelector.EventItem]
    let selected: EventSelector.EventItem.ID?
    let onEventTapped: (EventSelector.EventItem) -> Void
    
    public init(
        events: [EventSelector.EventItem],
        selected: EventSelector.EventItem.ID?,
        onEventTapped: @escaping (EventSelector.EventItem) -> Void
    ) {
        self.events = events
        self.selected = selected
        self.onEventTapped = onEventTapped
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            ForEach(events) { event in
                EventCard(
                    title: event.name,
                    active: selected == event.id,
                    lifetimeTagConf: event.lifetimeTagConf
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    onEventTapped(event)
                }
            }
        }
    }
}

#Preview {
    let selected = UUID().uuidString
    
    return EventList(
        events: [
            .init(id: selected, name: "冥想")
        ],
        selected: selected
    ) { event in
        print("select event: \(event.name)")
    }
}
