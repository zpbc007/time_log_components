// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Combine

@available(iOS 17.0, *)
public struct KeyboardEditor: View {
    @Binding var visible: Bool
    @State private var editorText = "editor text"
    @State private var title = ""
    @State private var desc = ""
    
    public init(visible: Binding<Bool>) {
        self._visible = visible
    }
    
    public var body: some View {
        if visible {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .onTapGesture {
                        withAnimation {
                            visible = false
                        }
                    }
                
                ToolbarContent(
                    title: $title,
                    desc: $desc,
                    visible: $visible
                )
                .transition(.asymmetric(insertion: .slide, removal: .slide))
            }
        } else {
            EmptyView()
        }
//        .KeyboardAwarePadding()
    }
}

@available(iOS 17.0, *)
struct ToolbarContent: View {
    enum Field: Hashable {
        case title
        case desc
    }
    @Binding var title: String
    @Binding var desc: String
    @Binding var visible: Bool
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            TextField("标题", text: $title)
                .focused($focusedField, equals: .title)
            
            TextField("描述", text: $desc, axis: .vertical)
                .lineLimit(5...10)
                .focused($focusedField, equals: .desc)
                        
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "tag")
                }
                
                Spacer()
                
                Button {
                    withAnimation{
                        visible = false
                    }
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
        .padding()
        .background(.gray, in: .rect(topLeadingRadius: 10, topTrailingRadius: 10))
        .onAppear() {
            focusedField = .title
        }
        .onChange(of: visible) { oldValue, newValue in
            if !visible {
                focusedField = nil
            }
        }
    }
}

struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
       ).eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(keyboardHeightPublisher) { self.keyboardHeight = $0 }
    }
}

extension View {
    func KeyboardAwarePadding() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier())
    }
}

#Preview {
    @available(iOS 17.0, *)
    struct TestView: View {
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
                    KeyboardEditor(visible: $showAdd)
                }
            }
        }
    }
    
    if #available(iOS 17.0, *) {
        return TestView()
    } else {
        return EmptyView()
    }
}
