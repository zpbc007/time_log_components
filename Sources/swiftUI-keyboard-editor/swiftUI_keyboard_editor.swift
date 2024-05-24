// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Combine

public struct KeyboardEditor: View {
    @State private var editorText = "editor text"
    @State private var title = ""
    @State private var desc = ""
    
    public init() {}
    
    public var body: some View {
        VStack {
            Spacer()
            
            ToolbarContent(title: $title, desc: $desc)
        }
//        .KeyboardAwarePadding()
    }
}

struct ToolbarContent: View {
    enum Field: Hashable {
        case title
        case desc
    }
    @Binding var title: String
    @Binding var desc: String
    @FocusState private var focusedField: Field?
    
    var body: some View {
        Form {
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
                    focusedField = nil
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                focusedField = .title
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

//#Preview {
//    KeyboardEditor()
//}

#Preview {
    ToolbarContent(title: .constant("title"), desc: .constant("desc"))
}
