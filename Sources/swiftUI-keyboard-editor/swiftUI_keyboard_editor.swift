// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct KeyboardEditor: View {
    @State private var text = "xxxx"
    @FocusState var focused: Bool
    
    public var body: some View {
        TextEditor(text: $text)
            .focused($focused)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("xxx") {
                        print("click")
                    }
                }
            }
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    focused = true
                }
            }
    }
}

#Preview {
    KeyboardEditor()
}
