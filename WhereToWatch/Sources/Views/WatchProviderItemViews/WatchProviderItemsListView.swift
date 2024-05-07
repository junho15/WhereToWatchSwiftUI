import SwiftUI
import MovieDatabaseAPI

struct WatchProviderItemsListView: View {
    let flatrateItems: [WatchProviderItem]
    let buyItems: [WatchProviderItem]
    let adsItems: [WatchProviderItem]
    let rentItems: [WatchProviderItem]
    let freeItems: [WatchProviderItem]
    let itemHeight: CGFloat
    let emptyItemHeight: CGFloat
    let titleLeadingSpacing: CGFloat

    private var notEmptyItemsCount: Int {
        [flatrateItems, buyItems, adsItems, rentItems, freeItems].filter { $0.isEmpty == false }.count
    }

    private var stackHeight: CGFloat {
        if notEmptyItemsCount == .zero {
            emptyItemHeight
        } else {
            itemHeight * CGFloat(notEmptyItemsCount) + Constants.justWatchImageHeight + Constants.stackSpacing
        }
    }

    init(flatrateItems: [WatchProviderItem],
         buyItems: [WatchProviderItem],
         adsItems: [WatchProviderItem],
         rentItems: [WatchProviderItem],
         freeItems: [WatchProviderItem],
         itemHeight: CGFloat = Constants.itemHeight,
         emptyItemHeight: CGFloat = Constants.emptyItemHeight,
         titleLeadingSpacing: CGFloat = Constants.titleLeadingSpacing
    ) {
        self.flatrateItems = flatrateItems
        self.buyItems = buyItems
        self.adsItems = adsItems
        self.rentItems = rentItems
        self.freeItems = freeItems
        self.itemHeight = itemHeight
        self.emptyItemHeight = emptyItemHeight
        self.titleLeadingSpacing = titleLeadingSpacing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.stackSpacing) {
            if flatrateItems.isEmpty == false {
                Text(WatchProviderType.flatrate.title)
                    .padding(.leading, titleLeadingSpacing)
                WatchProviderItemsCollectionView(watchProviderItems: flatrateItems)
            }
            if buyItems.isEmpty == false {
                Text(WatchProviderType.buy.title)
                    .padding(.leading, titleLeadingSpacing)
                WatchProviderItemsCollectionView(watchProviderItems: buyItems)
            }
            if adsItems.isEmpty == false {
                Text(WatchProviderType.ads.title)
                    .padding(.leading, titleLeadingSpacing)
                WatchProviderItemsCollectionView(watchProviderItems: adsItems)
            }
            if rentItems.isEmpty == false {
                Text(WatchProviderType.rent.title)
                    .padding(.leading, titleLeadingSpacing)
                WatchProviderItemsCollectionView(watchProviderItems: rentItems)
            }
            if freeItems.isEmpty == false {
                Text(WatchProviderType.free.title)
                    .padding(.leading, titleLeadingSpacing)
                WatchProviderItemsCollectionView(watchProviderItems: freeItems)
            }

            if notEmptyItemsCount == .zero {
                Text("NO_PLACE_MESSAGE")
            } else {
                HStack {
                    Spacer()
                    Image("JustWatch")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Constants.justWatchImageHeight)
                }
            }
        }
        .frame(height: stackHeight)
    }
}

extension WatchProviderItemsListView {
    private enum Constants {
        static let itemHeight = CGFloat(120)
        static let emptyItemHeight = CGFloat(50)
        static let titleLeadingSpacing = CGFloat(5)
        static let stackSpacing = CGFloat(5)
        static let justWatchImageHeight = CGFloat(20)
    }
}

#Preview {
    ScrollView(.vertical) {
        VStack(spacing: 10) {
            WatchProviderItemsListView(
                flatrateItems: PreviewData.watchProviderItems,
                buyItems: PreviewData.watchProviderItems,
                adsItems: PreviewData.watchProviderItems,
                rentItems: [],
                freeItems: []
            )
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))

            WatchProviderItemsListView(
                flatrateItems: [],
                buyItems: [],
                adsItems: [],
                rentItems: [],
                freeItems: []
            )
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        }
    }
}
