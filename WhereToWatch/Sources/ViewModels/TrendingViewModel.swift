import SwiftUI
import MovieDatabaseAPI

@MainActor
final class TrendingViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var movieMediaItems: [MediaItem]
    @Published var tvShowMediaItems: [MediaItem]

    private let movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol
    private let genresListFetcher: GenresListFetcherProtocol

    // MARK: Lifecycle

    init(
        movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol,
        genresListFetcher: GenresListFetcherProtocol,
        movieMediaItems: [MediaItem] = [],
        tvShowMediaItems: [MediaItem] = []
    ) {
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
        self.genresListFetcher = genresListFetcher
        self.movieMediaItems = movieMediaItems
        self.tvShowMediaItems = tvShowMediaItems
    }
}

// MARK: - Methods

extension TrendingViewModel {
    func fetchTrendingMovies(of timeWindow: MovieDatabaseURL.TimeWindow) async throws {
        guard let languageCode, let languageCountryCode else { return }

        let genresList = try await genresListFetcher.fetchMovieGenresList(languageCode: languageCode)

        let fetchedTrendingMovies = try await movieDatabaseAPIClient.fetchTrendingMovies(
            timeWindow: timeWindow,
            language: languageCountryCode
        )

        self.movieMediaItems = fetchedTrendingMovies.results.map { movie in
            MediaItem(media: movie, genreList: genresList)
        }
    }

    func fetchTrendingTVShows(of timeWindow: MovieDatabaseURL.TimeWindow) async throws {
        guard let languageCode, let languageCountryCode else { return }

        let genresList = try await genresListFetcher.fetchTVShowGenresList(languageCode: languageCode)

        let fetchedTrendingTVShows = try await movieDatabaseAPIClient.fetchTrendingTVShows(
            timeWindow: timeWindow,
            language: languageCountryCode
        )

        self.tvShowMediaItems = fetchedTrendingTVShows.results.map { tvShow in
            MediaItem(media: tvShow, genreList: genresList)
        }
    }
}
