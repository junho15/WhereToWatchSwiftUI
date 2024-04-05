import SwiftUI
import MovieDatabaseAPI

@MainActor
final class TrendingViewModel: ObservableObject, LocaleRepresentable {
    @Published var movieMediaItems: [MediaItem]
    @Published var tvShowMediaItems: [MediaItem]

    private let movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol
    private let genresListFetcher: GenresListFetcherProtocol

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

    func fetchTrendingTvShows(of timeWindow: MovieDatabaseURL.TimeWindow) async throws {
        guard let languageCode, let languageCountryCode else { return }

        let genresList = try await genresListFetcher.fetchTvShowGenresList(languageCode: languageCode)

        let fetchedTrendingTvShows = try await movieDatabaseAPIClient.fetchTrendingTVShows(
            timeWindow: timeWindow,
            language: languageCountryCode
        )

        self.tvShowMediaItems = fetchedTrendingTvShows.results.map { tvShow in
            MediaItem(media: tvShow, genreList: genresList)
        }
    }
}
