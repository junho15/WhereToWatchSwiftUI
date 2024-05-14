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
            (itemHeight + Constants.stackSpacing) * CGFloat(notEmptyItemsCount)
            + Constants.justWatchImageHeight
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
                Section {
                    WatchProviderItemsCollectionView(watchProviderItems: flatrateItems)
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                } header: {
                    Text(WatchProviderType.flatrate.title)
                        .padding(.leading, titleLeadingSpacing)
                }

            }

            if buyItems.isEmpty == false {
                Section {
                    WatchProviderItemsCollectionView(watchProviderItems: buyItems)
                        .background(Constants.backgroundStyle)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))

                } header: {
                    Text(WatchProviderType.buy.title)
                        .padding(.leading, titleLeadingSpacing)
                }
            }

            if adsItems.isEmpty == false {
                Section {
                    WatchProviderItemsCollectionView(watchProviderItems: adsItems)
                        .background(Constants.backgroundStyle)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                } header: {
                    Text(WatchProviderType.ads.title)
                        .padding(.leading, titleLeadingSpacing)
                }
            }

            if rentItems.isEmpty == false {
                Section {
                    WatchProviderItemsCollectionView(watchProviderItems: rentItems)
                        .background(Constants.backgroundStyle)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                } header: {
                    Text(WatchProviderType.rent.title)
                        .padding(.leading, titleLeadingSpacing)
                }
            }

            if freeItems.isEmpty == false {
                Section {
                    WatchProviderItemsCollectionView(watchProviderItems: freeItems)
                        .background(Constants.backgroundStyle)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                } header: {
                    Text(WatchProviderType.free.title)
                        .padding(.leading, titleLeadingSpacing)
                }
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
                .padding(.top, Constants.stackSpacing)
            }
        }
        .frame(height: stackHeight)
    }
}

extension WatchProviderItemsListView {
    private enum Constants {
        static let itemHeight = CGFloat(120)
        static let cornerRadius = CGFloat(10)
        static let emptyItemHeight = CGFloat(50)
        static let titleLeadingSpacing = CGFloat(5)
        static let stackSpacing = CGFloat(10)
        static let justWatchImageHeight = CGFloat(20)
        static let backgroundStyle = BackgroundStyle.background
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
