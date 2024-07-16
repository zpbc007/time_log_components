// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Combine

public struct KeyboardEditor<ContentView: View>: View {
    let bgColor: Color
    let content: () -> ContentView
    let dismiss: () -> Void
    
    public init(
        bgColor: Color,
        dismiss: @escaping () -> Void,
        content: @escaping () -> ContentView
    ) {
        self.bgColor = bgColor
        self.dismiss = dismiss
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.0001))
                .onTapGesture(perform: dismiss)
                .ignoresSafeArea()
            
            content()
                .background(bgColor, in: .rect(topLeadingRadius: 10, topTrailingRadius: 10))
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
                        bgColor: .white,
                        dismiss: {
                            showAdd = false
                        }
                    ) {
                        VStack {
                            TextField("任务名称", text: $title)
                                .font(.title3)
                            
                            TextField("任务描述", text: $desc)
                                .font(.callout)
                            
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
    }
    
    return TestView()
}
