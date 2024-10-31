//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/6/5.
//

import SwiftUI

struct TLLine { 
    // 日期下面的 padding
    static let DateBottomPadding: CGFloat = 15
    static let StartTimeMinHeight: CGFloat = 5
    static let EndTimeMinHeight: CGFloat = 30
}

extension TLLine {
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
                    
                    Vertical()
                        .frame(minHeight: TLLine.DateBottomPadding)
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

extension TLLine {
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
                
                Vertical()
                    .frame(minHeight: TLLine.StartTimeMinHeight)
                
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

extension TLLine {
    struct Vertical: View {
        var body: some View {
            VerticalLineShape()
                .stroke(style: StrokeStyle(lineWidth: 1))
                .frame(width: 1)
        }
    }
}

extension TLLine {
    struct Horizental: View {
        var body: some View {
            HorizentalLineShape()
                .stroke(style: StrokeStyle(lineWidth: 1))
                .frame(height: 1)
        }
    }
}

extension TLLine {
    struct Active: View {
        var body: some View {
            ActiveLineShape()
                .stroke(style: StrokeStyle(lineWidth: 2))
                .frame(height: 10)
        }
    }
}

extension TLLine {
    struct VerticalLineShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.width / 2, y: 0))
            path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
            
            return path
        }
    }
}

extension TLLine {
    struct HorizentalLineShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.height / 2))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
            
            return path
        }
    }
}

extension TLLine {
    struct ActiveLineShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            // 绘制横线
            path.move(to: CGPoint(x: 0, y: rect.height / 2))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
            
            // 绘制竖线
            path.move(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: 0, y: rect.height))
            
            return path
        }
    }
}

#Preview("active line") {
    TLLine.Active()
        .padding()
}

#Preview("line") {
    VStack(spacing: 0) {
        HStack {
            VStack(alignment: .trailing) {
                Spacer()
                Text("1")
            }.frame(width: 50, height: 100)
            
            TLLine.Vertical()
            
            Spacer()
        }
        
        TLLine.Horizental()
            .frame(height: 1)
        
        HStack {
            VStack(alignment: .trailing) {
                Spacer()
                Text("2")
            }.frame(width: 50, height: 100)
            
            TLLine.Vertical()
            
            Spacer()
        }
        
    }
}

#Preview {
    ScrollView {
        Text("real line")
        
        
        TLLine.WithDate(date: .now)
        
        HStack {
            TLLine.WithTime(startTime: .now, endTime: .now.addingTimeInterval(60))
            
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(.black)
                .frame(height: 100)
                .padding()
        }
        
        HStack {
            TLLine.WithTime(startTime: .now.addingTimeInterval(180), endTime: nil)
            
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(.black)
                .frame(height: 100)
                .padding()
        }
    }
}
