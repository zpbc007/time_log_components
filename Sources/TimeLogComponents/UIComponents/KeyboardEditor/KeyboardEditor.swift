// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Combine

public struct KeyboardEditor<ActionView: View>: View {
    let titlePlaceholder: String
    let descPlaceholder: String
    let bgColor: Color
    @Binding var title: String
    @Binding var desc: String
    let action: () -> ActionView
    let dismiss: () -> Void
    
    public init(
        titlePlaceholder: String,
        descPlaceholder: String,
        bgColor: Color,
        title: Binding<String>,
        desc: Binding<String>,
        dismiss: @escaping () -> Void,
        action: @escaping () -> ActionView
    ) {
        self.titlePlaceholder = titlePlaceholder
        self.descPlaceholder = descPlaceholder
        self.bgColor = bgColor
        self._title = title
        self._desc = desc
        self.dismiss = dismiss
        self.action = action
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.0001))
                .onTapGesture(perform: dismiss)
                .ignoresSafeArea()
            
            ContentView(
                titlePlaceholder: titlePlaceholder,
                descPlaceholder: descPlaceholder,
                bgColor: bgColor,
                title: $title,
                desc: $desc,
                action: action
            )
        }
    }
}

#Preview {
    struct TestView: View {
        @State private var title = ""
        @State private var desc = ""
        @State private var showAdd: Bool = false
        
        var body: some View {
            ZStack {
                List {
                    ForEach(1..<100) {item in
                        Text("item: \(item)")
                    }
                }.overlay(alignment: .bottomTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .padding()
                            .foregroundStyle(.primary)
                            .font(.title2)
                            .bold()
                            .background(
                                Circle()
                                    .fill(.gray)
                            )
                            .padding(.horizontal)
                    }
                }
                
                if showAdd {
                    KeyboardEditor(
                        titlePlaceholder: "任务名称",
                        descPlaceholder: "任务描述",
                        bgColor: .white,
                        title: $title,
                        desc: $desc,
                        dismiss: {
                            showAdd = false
                        }
                    ) {
                        HStack {
                            Menu {
                                ForEach(1..<100) { item in
                                    Button("tag-\(item)") {}
                                }
                            } label: {
                                Image(systemName: "tag")
                            }
                            
                            Spacer()
                                                        
                            Button {
                                
                            } label: {
                                Image(systemName: "arrow.up.circle")
                            }
                        }
                    }
                }
            }
        }
    }
    
    return TestView()
}
