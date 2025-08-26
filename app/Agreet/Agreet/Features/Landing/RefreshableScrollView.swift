import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @State private var isRefreshing = false
    let action: () async -> Void
    let content: () -> Content
    
    init(action: @escaping () async -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            ScrollView {
                content()
            }
            .refreshable {
                await action()
            }
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    RefreshHeader(isRefreshing: $isRefreshing) {
                        Task {
                            await action()
                            withAnimation {
                                isRefreshing = false
                            }
                        }
                    }
                    
                    content()
                }
            }
        }
    }
}

private struct RefreshHeader: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            if offset > 50 && !isRefreshing {
                ProgressView()
                    .onAppear {
                        isRefreshing = true
                        onRefresh()
                    }
                    .frame(width: geo.size.width, height: 50, alignment: .center)
            } else if isRefreshing {
                ProgressView()
                    .frame(width: geo.size.width, height: 50, alignment: .center)
            } else {
                Color.clear
                    .frame(width: geo.size.width, height: 50)
                    .background(
                        Text("Pull to refresh...")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    )
            }
        }
        .frame(height: isRefreshing ? 50 : 0)
        .opacity(isRefreshing ? 1 : min(Double(offset) / 50.0, 1.0))
        .background(GeometryReader { proxy in
            Color.clear.preference(key: OffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
        })
        .onPreferenceChange(OffsetPreferenceKey.self) { value in
            offset = value
        }
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
