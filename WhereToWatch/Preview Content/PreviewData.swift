import UIKit
import MovieDatabaseAPI

enum PreviewData {
    static let creditsData: Credits = load("CreditsData")
    static let genreListData: GenreList = load("GenreListData")
    static let movieDetailData: Movie = load("MovieDetailData")
    static let moviePageData: Page<Movie> = load("MoviePageData")
    static let similarMovieData: Page<Movie> = load("SimilarMovieData")
    static let similarTVShowData: Page<TVShow> = load("SimilarTVShowData")
    static let tvShowDetailData: TVShow = load("TVShowDetailData")
    static let tvShowPageData: Page<TVShow> = load("TVShowPageData")
    static let watchProviderResultData: WatchProviderResult = load("WatchProviderResultData")

    static let movieDatabaseAPIClient = MovieDatabaseAPIClient(apiKey: Secrets.apiKey)
    static let genresListFetcher = GenresListFetcher(movieDatabaseAPIClient: movieDatabaseAPIClient)
    static let favoriteService = FavoriteService.shared

    static var mediaItem: MediaItem {
        MediaItem(media: movieDetailData, genreList: genreListData)
    }

    static var mediaItems: [MediaItem] {
        moviePageData.results.map { movie in
            MediaItem(media: movie, genreList: genreListData)
        }
    }

    static var watchProviderItems: [WatchProviderItem] {
        watchProviderResultData.results!["US"]!.results[WatchProviderType.buy]!.map {
            WatchProviderItem(watchProvider: $0)
        }
    }

    @MainActor
    static var creditsViewModel: CreditsViewModel {
        CreditsViewModel(
            mediaItem: mediaItem,
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            creditItems: PreviewData.creditsData.cast.map { CreditItem(credit: $0) }
        )
    }

    @MainActor
    static var favoritesViewModel: FavoritesViewModel {
        FavoritesViewModel(
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            favoriteService: favoriteService,
            mediaItems: mediaItems,
            sortOption: .registrationDate
        )
    }

    @MainActor
    static var mediaDetailViewModel: MediaDetailViewModel {
        MediaDetailViewModel(mediaItem: mediaItem, favoriteService: favoriteService)
    }

    @MainActor
    static var searchViewModel: SearchViewModel {
        SearchViewModel(
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            searchText: "",
            movieMediaItems: mediaItems,
            tvShowMediaItems: mediaItems)
    }

    @MainActor
    static var similarViewModel: SimilarViewModel {
        SimilarViewModel(
            mediaItem: mediaItem,
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            similarMediaItem: mediaItems
        )
    }

    @MainActor
    static var defaultWatchProviderViewModel: WatchProviderViewModel {
        WatchProviderViewModel(
            mediaItem: PreviewData.mediaItem,
            movieDatabaseAPIClient: PreviewData.movieDatabaseAPIClient,
            flatrateItems: PreviewData.watchProviderItems,
            buyItems: PreviewData.watchProviderItems,
            adsItems: PreviewData.watchProviderItems,
            rentItems: [],
            freeItems: []
        )
    }

    @MainActor
    static var emptyWatchProviderViewModel: WatchProviderViewModel {
        WatchProviderViewModel(
            mediaItem: PreviewData.mediaItem,
            movieDatabaseAPIClient: PreviewData.movieDatabaseAPIClient,
            flatrateItems: [],
            buyItems: [],
            adsItems: [],
            rentItems: [],
            freeItems: []
        )
    }

    @MainActor
    static var trendingViewModel: TrendingViewModel {
        TrendingViewModel(
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            movieMediaItems: mediaItems,
            tvShowMediaItems: mediaItems
        )
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    private static func load<T: Decodable>(_ name: String) -> T {
        guard let jsonDataAsset = NSDataAsset(name: name) else {
            fatalError("\(name)를 찾을 수 없습니다.")
        }

        do {
            return try decoder.decode(T.self, from: jsonDataAsset.data)
        } catch {
            fatalError("디코딩에 실패했습니다. \(error.localizedDescription)")
        }
    }
}
