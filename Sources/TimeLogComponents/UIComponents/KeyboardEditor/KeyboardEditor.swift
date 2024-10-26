// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Combine

public struct KeyboardEditor<ContentView: View>: View {
    let bgColor: Color
    let content: (_ size: CGSize) -> ContentView
    let dismiss: () -> Void
    @State private var contentSize: CGSize = .zero
    @State private var keyboardHeight: CGFloat = .zero
    
    public init(
        bgColor: Color,
        dismiss: @escaping () -> Void,
        content: @escaping (_ size: CGSize) -> ContentView
    ) {
        self.bgColor = bgColor
        self.dismiss = dismiss
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                // 获取可用空间
                Color.clear
                    .onAppear {
                        DispatchQueue.main.async {
                            contentSize = .init(
                                width: proxy.size.width,
                                height: proxy.size.height - proxy.safeAreaInsets.top
                            )
                        }
                    }
            }
            
            Rectangle()
                .fill(Color.black.opacity(0.6))
                .onTapGesture(perform: dismiss)
                .ignoresSafeArea()
                .transition(.opacity)
            
            content(.init(width: contentSize.width, height: contentSize.height - keyboardHeight))
                .background(
                    bgColor,
                    in: .rect(topLeadingRadius: 10, topTrailingRadius: 10)
                )
                .transition(.move(edge: .bottom))
        }.onReceive(keyboardHeightPublisher, perform: { height in
            keyboardHeight = height
        })
    }
    
    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map {
                ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
            }
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).map { _ in 0 })
            .eraseToAnyPublisher()
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
                        withAnimation {
                            showAdd = true
                        }
                        
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
                    ) { size in
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
