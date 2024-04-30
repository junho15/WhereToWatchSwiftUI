import SwiftUI
import MovieDatabaseAPI

@MainActor
final class WatchProviderViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var flatrateItems: [WatchProviderItem]
    @Published var buyItems: [WatchProviderItem]
    @Published var adsItems: [WatchProviderItem]
    @Published var rentItems: [WatchProviderItem]
    @Published var freeItems: [WatchProviderItem]

    private let mediaItem: MediaItem
    private let movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol

    // MARK: Lifecycle

    init(
        mediaItem: MediaItem,
        movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol,
        flatrateItems: [WatchProviderItem] = [],
        buyItems: [WatchProviderItem] = [],
        adsItems: [WatchProviderItem] = [],
        rentItems: [WatchProviderItem] = [],
        freeItems: [WatchProviderItem] = []
    ) {
        self.mediaItem = mediaItem
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
        self.flatrateItems = flatrateItems
        self.buyItems = buyItems
        self.adsItems = adsItems
        self.rentItems = rentItems
        self.freeItems = freeItems
    }
}

// MARK: - Methods

extension WatchProviderViewModel {
    func fetchWatchProviders() async throws {

        let watchProviderResult: WatchProviderResult

        switch mediaItem.mediaType {
        case .movie:
            watchProviderResult = try await movieDatabaseAPIClient.fetchMovieWatchProviders(movieID: mediaItem.id)
        case .tvShow:
            watchProviderResult = try await movieDatabaseAPIClient.fetchTVShowWatchProviders(tvShowID: mediaItem.id)
        }

        guard let countryCode, let watchProviderList = watchProviderResult.results?[countryCode] else { return }

        watchProviderList.results.forEach { watchProviderType, watchProviders in
            let watchProviderItems = watchProviders.map { watchProvider in
                WatchProviderItem(watchProvider: watchProvider)
            }

            switch watchProviderType {
            case .flatrate:
                flatrateItems = watchProviderItems
            case .buy:
                buyItems = watchProviderItems
            case .ads:
                adsItems = watchProviderItems
            case .rent:
                rentItems = watchProviderItems
            case .free:
                freeItems = watchProviderItems
            }
        }
    }
}
