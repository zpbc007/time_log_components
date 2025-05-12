//
//  SwiftUIView.swift
//  time-log-components
//
//  Created by zhaopeng on 2025/5/10.
//

import SwiftUI

public struct TypeEffectText: View {
    let finalText: String
    @State private var text: AttributedString = ""
    @State private var typingTask: Task<Void, Error>?
    
    init(_ text: String) {
        self.finalText = text
    }
    
    public var body: some View {
        Text(text)
            .font(.callout)
            .monospaced()
            .multilineTextAlignment(.leading)
            .task {
                typeWriter()
            }.onChange(of: finalText) { oldValue, newValue in
                typingTask?.cancel()
                typeWriter()
            }
    }
    
    private func typeWriter(at position: Int = 0) {
        typingTask?.cancel()
        typingTask = Task {
            let defaultAttributes = AttributeContainer()
            text = AttributedString(
                finalText,
                attributes: defaultAttributes.foregroundColor(.clear)
            )
            
            var index = text.startIndex
            while index < text.endIndex {
                try Task.checkCancellation()

                // Update the style
                text[text.startIndex...index]
                    .setAttributes(defaultAttributes)

                // Wait
                try await Task.sleep(for: .milliseconds(50))

                // Advance the index, character by character
                index = text.index(afterCharacter: index)
            }
        }
    }
}

#Preview {
    struct Playground: View {
        @State private var message = "new message"
        
        var body: some View {
            VStack {
                Button("change message") {
                    message = message == "new message" ? "看到您今日在生存领域投入了7小时，工作领域仅有1小时的记录，而自由时间投入了5小时，还有11小时的时间未被记录下来。首先，我想对您说，每个人的每一天都是宝贵的，您已经在这三个领域做出了努力，这非常棒！\n\n在交叉分析中，我注意到了几个地方我们可以进行微调。生存方面，您的时间投入恰到好处，保证了基本的生理需求，但或许可以看看是否有可能提高生存活动的效率，比如优化作息时间，为工作和自由时间争取更多空间。\n\n工作领域只有1小时的记录，这显然低于常规的工作时长。我建议可以引入“四象限工作法”，即把工作按照重要紧急程度分为四类，优先处理重要且紧急的事务，这样可以在有限的时间内提高工作效率。同时，不要忘了身体健康，平衡好工作与生活。\n\n自由时间有5小时的投入，这是一个很好的开始，但仍有提升的空间。我鼓励您继续追求更多的自由时间，无论是用于个人成长还是陪伴家人，这些时间都是精神滋养的重要来源。\n\n至于未被记录的11小时，这是一个相当大的时间块。我建议您开始使用‘三时’的计时器功能，在处理各项事务时开启计时，这样可以帮助您更清晰地了解时间流向，同时在每日总结时回顾并记录下遗漏的时间。\n\n让我们从小步骤开始，为了明天能更高效地使用时间，我建议可以从以下两个方面进行微调：\n1. 选择一项工作活动，尝试使用四象限工作法，看看是否能提高工作效率。\n2. 开始记录未被记录的3小时，哪怕是从明天开始，这样我们就能更清晰地看到时间分配的全貌。\n\n记住，成长是一个持续的过程，每一次小小的努力都会让未来的您感激。您已经做得很好了，让我们携手让明天更加精彩！" : "new message"
                }
                
                ScrollView {
                    TypeEffectText(message).padding()
                }
                
            }
        }
    }
    
    return Playground()
}
