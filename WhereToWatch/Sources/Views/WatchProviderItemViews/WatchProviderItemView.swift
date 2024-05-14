import SwiftUI

struct WatchProviderItemView: View {
    let watchProviderItem: WatchProviderItem

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                AsyncImageView(url: watchProviderItem.logoURL)
                    .aspectRatio(Constants.imageViewRatio, contentMode: .fit)

                if let providerName = watchProviderItem.providerName {
                    Text(providerName)
                        .font(.caption2)
                        .lineLimit(Constants.textLineLimit)
                        .frame(width: geometry.size.width)
                }
            }
        }
    }
}

extension WatchProviderItemView {
    private enum Constants {
        static let imageViewRatio = CGFloat(1)
        static let textLineLimit = 1
    }
}

#Preview {
    GeometryReader { geometry in
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(PreviewData.watchProviderItems) { watchProvider in
                    WatchProviderItemView(watchProviderItem: watchProvider)
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        .frame(width: geometry.size.width * 1/3, height: geometry.size.width * 1/5)
                }
            }
        }
        .scrollTargetBehavior(.paging)
    }
}
