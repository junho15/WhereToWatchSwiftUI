import SwiftUI
import MovieDatabaseAPI

@MainActor
final class SimilarViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var similarMediaItem: [MediaItem]

    private let mediaItem: MediaItem
    private let movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol
    private let genresListFetcher: GenresListFetcherProtocol
    private var lastPage: Int
    private var totalPage: Int

    // MARK: Lifecycle

    init(
        mediaItem: MediaItem,
        movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol,
        genresListFetcher: GenresListFetcherProtocol,
        similarMediaItem: [MediaItem] = [],
        lastPage: Int = 0,
        totalPage: Int = 1
    ) {
        self.mediaItem = mediaItem
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
        self.genresListFetcher = genresListFetcher
        self.similarMediaItem = similarMediaItem
        self.lastPage = lastPage
        self.totalPage = totalPage
    }
}

// MARK: - Methods

extension SimilarViewModel {
    func fetchSimilarMedia() async throws {
        switch mediaItem.mediaType {
        case .movie:
            try await fetchSimilarMovies(id: mediaItem.id, page: 1)
        case .tvShow:
            try await fetchSimilarTVShows(id: mediaItem.id, page: 1)
        }
    }

    func fetchMoreSimilarMedia() async throws {
        guard lastPage < totalPage else { return }

        switch mediaItem.mediaType {
        case .movie:
            try await fetchSimilarMovies(id: mediaItem.id, page: lastPage + 1)
        case .tvShow:
            try await fetchSimilarTVShows(id: mediaItem.id, page: lastPage + 1)
        }
    }

    private func fetchSimilarMovies(id: MediaItem.ID, page: Int) async throws {
        guard let languageCode, let languageCountryCode else { return }

        let genresList = try await genresListFetcher.fetchMovieGenresList(languageCode: languageCode)

        let fetchedPage = try await movieDatabaseAPIClient.fetchSimilarMovies(
            movieID: id, language: languageCountryCode, page: page
        )

        self.lastPage = fetchedPage.page
        self.totalPage = fetchedPage.totalPages

        let fetchedMediaItem = fetchedPage.results.map { movie in
            MediaItem(media: movie, genreList: genresList)
        }

        if fetchedPage.page == 1 {
            self.similarMediaItem = fetchedMediaItem
        } else {
            self.similarMediaItem += fetchedMediaItem
        }
    }

    private func fetchSimilarTVShows(id: MediaItem.ID, page: Int) async throws {
        guard let languageCode, let languageCountryCode else { return }

        let genresList = try await genresListFetcher.fetchTVShowGenresList(languageCode: languageCode)

        let fetchedPage = try await movieDatabaseAPIClient.fetchSimilarTVShows(
            tvShowID: id, language: languageCountryCode, page: page
        )

        self.lastPage = fetchedPage.page
        self.totalPage = fetchedPage.totalPages

        let fetchedMediaItem = fetchedPage.results.map { tvShow in
            MediaItem(media: tvShow, genreList: genresList)
        }

        if fetchedPage.page == 1 {
            self.similarMediaItem = fetchedMediaItem
        } else {
            self.similarMediaItem += fetchedMediaItem
        }
    }
}
