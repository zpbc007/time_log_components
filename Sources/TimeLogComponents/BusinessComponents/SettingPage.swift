//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/19.
//

import SwiftUI

public struct SettingPage: View {
    let user: FeedbackView.UserInfo?
    
    public init(user: FeedbackView.UserInfo?) {
        self.user = user
    }
    
    public var body: some View {
        Form {
            Section {
                UserInfoView(user: user)
            }
            
            NavigationLink {
                HelpCenterWebView()
                    .toolbar(.hidden, for: .tabBar)
            } label: {
                Label("新手指南", systemImage: "questionmark.circle")
            }
            
            NavigationLink {
                FeedbackView(user: user)
                    .toolbar(.hidden, for: .tabBar)
            } label: {
                Label("联系我们", systemImage: "phone.circle")
            }
        }
    }
}

extension SettingPage {
    struct UserInfoView: View {
        let user: FeedbackView.UserInfo?
        
        var body: some View {
            HStack {
                if let photoUrl = user?.photoUrl, !photoUrl.isEmpty {
                    AsyncImageLoader(urlString: photoUrl)
                        .padding(.trailing, 10)
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.trailing, 10)
                }
                
                Text(user?.displayName ?? "未设置昵称")
            }
        }
    }
}

extension SettingPage {
    struct AsyncImageLoader: View {
        let urlString:  String
        
        private let logger = TLLogger(context: String(describing: SettingPage.AsyncImageLoader.self))
        @State private var image: Image?
        
        var body: some View {
            VStack {
                if let image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 50, height: 50)
                }
            }.task {
                loadImage()
            }
        }
        
        private func loadImage() {
            guard let url = URL(string: urlString) else {
                return
            }
            
            Task {
                do {
                    let (imageData, _) = try await URLSession.shared.data(from: url)
                    if let uiImage = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            image = Image(uiImage: uiImage)
                        }
                    }
                } catch(let error) {
                    logger.error("fetch image for url: \(urlString) error: \(error)")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingPage(
            user: .init(
                uid: UUID().uuidString,
                displayName: "用户 xxx",
                photoUrl: "https://slab.com/static/b5ae12a602adf067eb2373415281d9fe/7aa54/banner.webp"
            )
        )
    }
}

#Preview("未设置") {
    NavigationStack {
        SettingPage(
            user: .init(
                uid: UUID().uuidString,
                displayName: nil,
                photoUrl: nil
            )
        )
    }
}
