import SwiftUI

struct WatchProviderItemsCollectionView: View {
    let watchProviderItems: [WatchProviderItem]
    let itemHeight: CGFloat

    init(watchProviderItems: [WatchProviderItem], itemHeight: CGFloat = Constants.itemHeight) {
        self.watchProviderItems = watchProviderItems
        self.itemHeight = itemHeight
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(spacing: Constants.spacing) {
                    ForEach(watchProviderItems) { watchProviderItem in
                        WatchProviderItemView(watchProviderItem: watchProviderItem)
                            .padding(Constants.itemPadding)
                            .frame(width: geometry.size.width * Constants.itemWidthRatio, height: itemHeight)
                    }
                }
            }
            .frame(height: itemHeight)
            .scrollTargetBehavior(.paging)
        }
    }
}

extension WatchProviderItemsCollectionView {
    private enum Constants {
        static let spacing = CGFloat.zero
        static let itemPadding = EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        static let itemWidthRatio = 1.0 / 3.0
        static let itemHeight = CGFloat(75)
    }
}

#Preview {
    WatchProviderItemsCollectionView(watchProviderItems: PreviewData.watchProviderItems, itemHeight: CGFloat(75))
}
