//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import SwiftUI

struct VDashedLine { 
    // 日期下面的 padding
    static let DateBottomPadding: CGFloat = 15
    static let StartTimeMinHeight: CGFloat = 5
    static let EndTimeMinHeight: CGFloat = 30
}

extension VDashedLine {
    struct WithDate: View {
        let date: Date
        
        private static let dateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter
        }()
        
        var day: String {
            if let day = Calendar.current.dateComponents([.day], from: date).day {
                String(day)
            } else {
                "-"
            }
        }
        
        var body: some View {
            HStack(alignment: .top) {
                VStack {
                    Text(day)
                        .font(.title)
                        .foregroundStyle(.primary)
                        .bold()
                    
                    RealLine()
                        .frame(minHeight: VDashedLine.DateBottomPadding)
                }
                .frame(width: 50)
                
                Text(Self.dateFormatter.string(from: date))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

extension VDashedLine {
    struct WithTime: View {
        let startTime: Date
        let endTime: Date?
        
        private let dateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter
        }()
        
        var body: some View {
            VStack {
                timeText(startTime)
                
                RealLine()
                    .frame(minHeight: VDashedLine.StartTimeMinHeight)
                
                if let endTime = endTime {
                    timeText(endTime)
                }
            }
            .frame(width: 50)
        }
        
        private func timeText(_ time: Date) -> some View {
            Text(dateFormatter.string(from: time))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

extension VDashedLine {
    struct RealLine: View {
        var body: some View {
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(width: 1)
        }
    }
}

extension VDashedLine {
    struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            return path
        }
    }
}

#Preview {
    ScrollView {
        VDashedLine.WithDate(date: .now)
        
        HStack {
            VDashedLine.WithTime(startTime: .now, endTime: .now.addingTimeInterval(60))
            
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(.black)
                .frame(height: 100)
                .padding()
        }
        
        HStack {
            VDashedLine.WithTime(startTime: .now.addingTimeInterval(180), endTime: nil)
            
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(.black)
                .frame(height: 100)
                .padding()
        }
    }
}
