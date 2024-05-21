import MovieDatabaseAPI

@MainActor
final class ViewModelProvider {

    // MARK: Properties

    static let shared = ViewModelProvider()

    @Injected private var movieDatabaseAPIClient: MovieDatabaseAPIClient
    @Injected private var genresListFetcher: GenresListFetcher
    @Injected private var favoriteService: FavoriteService

    // MARK: Lifecycle

    private init() {}
}

// MARK: - Methods

extension ViewModelProvider {
    func creditsViewModel(mediaItem: MediaItem, creditItems: [CreditItem] = []) -> CreditsViewModel {
        CreditsViewModel(
            mediaItem: mediaItem, movieDatabaseAPIClient: movieDatabaseAPIClient, creditItems: creditItems
        )
    }

    func favoritesViewModel(
        mediaItems: [MediaItem] = [], sortOption: FavoritesSortOption = .registrationDate
    ) -> FavoritesViewModel {
        FavoritesViewModel(
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            favoriteService: favoriteService,
            mediaItems: mediaItems,
            sortOption: sortOption
        )
    }

    func mediaDetailViewModel(mediaItem: MediaItem) -> MediaDetailViewModel {
        MediaDetailViewModel(mediaItem: mediaItem, favoriteService: favoriteService)
    }

    func searchViewModel(
        searchText: String = "",
        movieMediaItems: [MediaItem] = [],
        tvShowMediaItems: [MediaItem] = [],
        movieLastPage: Int = 0,
        movieTotalPage: Int = 1,
        tvShowLastPage: Int = 0,
        tvShowTotalPage: Int = 1
    ) -> SearchViewModel {
        SearchViewModel(
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            searchText: searchText,
            movieMediaItems: movieMediaItems,
            tvShowMediaItems: tvShowMediaItems,
            movieLastPage: movieLastPage,
            movieTotalPage: movieTotalPage,
            tvShowLastPage: tvShowLastPage,
            tvShowTotalPage: tvShowTotalPage
        )
    }

    func similarViewModel(
        mediaItem: MediaItem,
        similarMediaItem: [MediaItem] = [],
        lastPage: Int = 0,
        totalPage: Int = 1
    ) -> SimilarViewModel {
        SimilarViewModel(
            mediaItem: mediaItem,
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            similarMediaItem: similarMediaItem,
            lastPage: lastPage,
            totalPage: totalPage
        )
    }

    func trendingViewModel(
        movieMediaItems: [MediaItem] = [],
        tvShowMediaItems: [MediaItem] = []
    ) -> TrendingViewModel {
        TrendingViewModel(
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            movieMediaItems: movieMediaItems,
            tvShowMediaItems: tvShowMediaItems
        )
    }

    func watchProviderViewModel(
        mediaItem: MediaItem,
        flatrateItems: [WatchProviderItem] = [],
        buyItems: [WatchProviderItem] = [],
        adsItems: [WatchProviderItem] = [],
        rentItems: [WatchProviderItem] = [],
        freeItems: [WatchProviderItem] = []
    ) -> WatchProviderViewModel {
        WatchProviderViewModel(
            mediaItem: mediaItem,
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            flatrateItems: flatrateItems,
            buyItems: buyItems,
            adsItems: adsItems,
            rentItems: rentItems,
            freeItems: freeItems
        )
    }
}
