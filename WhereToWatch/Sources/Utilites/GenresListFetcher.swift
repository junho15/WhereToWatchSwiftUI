import MovieDatabaseAPI

protocol GenresListFetcherProtocol {
    typealias LanguageCode = String

    func fetchMovieGenresList(languageCode: LanguageCode) async throws -> GenreList
    func fetchTVShowGenresList(languageCode: LanguageCode) async throws -> GenreList
}

final actor GenresListFetcher: GenresListFetcherProtocol {

    // MARK: Properties

    private let movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol
    private var cachedMovieGenresList: [LanguageCode: GenreList]
    private var cachedTVShowGenresList: [LanguageCode: GenreList]

    // MARK: Lifecycle

    init(
        movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol,
        cachedMovieGenresList: [LanguageCode: GenreList] = [:],
        cachedTVShowGenresList: [LanguageCode: GenreList] = [:]
    ) {
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
        self.cachedMovieGenresList = cachedMovieGenresList
        self.cachedTVShowGenresList = cachedTVShowGenresList
    }
}

// MARK: - Methods

extension GenresListFetcher {
    func fetchMovieGenresList(languageCode: LanguageCode) async throws -> GenreList {
        if let cached = cachedMovieGenresList[languageCode] {
            return cached
        } else {
            let genresList = try await movieDatabaseAPIClient.fetchMovieGenresList(language: languageCode)
            cachedMovieGenresList[languageCode] = genresList
            return genresList
        }
    }

    func fetchTVShowGenresList(languageCode: LanguageCode) async throws -> GenreList {
        if let cached = cachedTVShowGenresList[languageCode] {
            return cached
        } else {
            let genresList = try await movieDatabaseAPIClient.fetchTVShowGenresList(language: languageCode)
            cachedTVShowGenresList[languageCode] = genresList
            return genresList
        }
    }
}
