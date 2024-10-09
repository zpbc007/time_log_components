//
//  SwiftUIView.swift
//  
//
//  Created by zhaopeng on 2024/7/19.
//

import SwiftUI

public struct SettingPage: View {
    @Binding var syncByICloud: Bool
    @Binding var isDemoMode: Bool
    
    public init(
        syncByICloud: Binding<Bool>,
        isDemoMode: Binding<Bool>
    ) {
        self._syncByICloud = syncByICloud
        self._isDemoMode = isDemoMode
    }
    
    public var body: some View {
        Form {
            NavigationLink {
                HelpCenterWebView()
                    .toolbar(.hidden, for: .tabBar)
            } label: {
                Label("新手指南", systemImage: "questionmark.circle")
            }
            
            NavigationLink {
                FeedbackView(user: nil)
                    .toolbar(.hidden, for: .tabBar)
            } label: {
                Label("联系我们", systemImage: "phone.circle")
            }

            if !isDemoMode {
                Toggle(
                    isOn: $syncByICloud,
                    label: {
                        HStack {
                            Text("通过 iCloud 同步")
                            PlusTag()
                        }
                    }
                )
            }
            
            Section(footer: Text("重启后，演示模式中的数据会被重置！")) {
                Toggle(
                    isOn: $isDemoMode.animation(),
                    label: {
                        HStack {
                            Text("演示模式")
                        }
                    }
                )
            }
        }
    }
}

extension SettingPage {
    struct PlusTag: View {
        var body: some View {
            Text("Plus")
                .font(.callout)
                .bold()
                .padding(6)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 10)
                )
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
    struct Playground: View {
        @State private var syncByICloud = false
        @State private var isDemoMode = false
        
        var body: some View {
            NavigationStack {
                SettingPage(
                    syncByICloud: $syncByICloud,
                    isDemoMode: $isDemoMode
                )
            }
        }
    }
    
    return Playground()
}
