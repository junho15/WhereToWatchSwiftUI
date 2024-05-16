import SwiftUI

struct MediaItemDetailView: View {
    @Binding var path: NavigationPath
    @ObservedObject var mediaDetailViewModel: MediaDetailViewModel
    @ObservedObject var creditsViewModel: CreditsViewModel
    @ObservedObject var similarViewModel: SimilarViewModel
    @ObservedObject var watchProviderViewModel: WatchProviderViewModel

    @MainActor
    private var mediaItem: MediaItem {
        mediaDetailViewModel.mediaItem
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: Constants.spacingDouble) {
                    MediaDetailHeaderView(
                        posterURL: mediaItem.posterURL,
                        backDropURL: mediaItem.backdropURL,
                        title: mediaItem.title,
                        year: mediaItem.year,
                        genre: mediaItem.genre
                    )
                    .frame(height: geometry.size.width * Constants.headerViewRatio)

                    WatchProviderItemsListView(
                        flatrateItems: watchProviderViewModel.flatrateItems,
                        buyItems: watchProviderViewModel.buyItems,
                        adsItems: watchProviderViewModel.adsItems,
                        rentItems: watchProviderViewModel.rentItems,
                        freeItems: watchProviderViewModel.freeItems
                    )
                    .task {
                        do {
                            try await watchProviderViewModel.fetchWatchProviders()
                        } catch {
                            // Handle error
                        }                    }

                    if let overview = mediaItem.overview {
                        Section {
                            Text(overview)
                                .padding()
                                .background(Constants.itemBackgroundStyle)
                                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                        } header: {
                            Text("OVERVIEW_HEADER")
                                .padding(.leading, Constants.textLeadingPadding)
                        }
                    }

                    Section {
                        CreditItemsCollectionView(
                            creditItems: creditsViewModel.creditItems,
                            itemHeight: Constants.collectionViewItemHeight
                        )
                        .frame(minHeight: Constants.collectionViewItemHeight)
                        .padding(.top, Constants.spacing)
                        .background(Constants.itemBackgroundStyle)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                        .task {
                            do {
                                try await creditsViewModel.fetchCredits()
                            } catch {
                                // Handle error
                            }
                        }
                    } header: {
                        Text("CREDITS_HEADER")
                            .padding(.leading, Constants.textLeadingPadding)
                    }

                    Section {
                        SimilarItemsCollectionView(
                            path: $path,
                            similarItems: similarViewModel.similarMediaItem,
                            itemHeight: Constants.collectionViewItemHeight,
                            onReachEnd: {
                                Task {
                                    do {
                                        try await similarViewModel.fetchMoreSimilarMedia()
                                    } catch {
                                        // Handle error
                                    }
                                }
                            }
                        )
                        .frame(minHeight: Constants.collectionViewItemHeight)
                        .padding(.bottom, Constants.spacing)
                        .background(Constants.itemBackgroundStyle)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                        .task {
                            do {
                                try await similarViewModel.fetchSimilarMedia()
                            } catch {
                                // Handle error
                            }
                        }
                    } header: {
                        Text("SIMILAR_HEADER")
                            .padding(.leading, Constants.textLeadingPadding)
                    }
                }
                .padding(Constants.stackPadding)
            }
            .frame(minWidth: 100, minHeight: 100)
            .background(Constants.backgroundColor)
        }
    }
}

extension MediaItemDetailView {
    private enum Constants {
        static let spacing = CGFloat(10)
        static let spacingDouble = spacing * 2.0
        static let cornerRadius = CGFloat(10)
        static let headerViewRatio = CGFloat(281)/CGFloat(500)
        static let textLeadingPadding = CGFloat(5)
        static let collectionViewItemHeight = CGFloat(200)
        static let stackPadding = EdgeInsets(top: 0, leading: spacing, bottom: spacing, trailing: spacing)
        static let backgroundColor = Color(uiColor: .systemGray6)
        static let itemBackgroundStyle = BackgroundStyle.background
    }
}

#Preview {
    MediaItemDetailView(
        path: .constant(NavigationPath()),
        mediaDetailViewModel: PreviewData.mediaDetailViewModel,
        creditsViewModel: PreviewData.creditsViewModel,
        similarViewModel: PreviewData.similarViewModel,
        watchProviderViewModel: PreviewData.defaultWatchProviderViewModel
    )
}
