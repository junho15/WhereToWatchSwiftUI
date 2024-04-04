import MovieDatabaseAPI

protocol GenresListFetcherProtocol {
    typealias LanguageCode = String

    func fetchMovieGenresList(languageCode: LanguageCode) async throws -> GenreList
    func fetchTvShowGenresList(languageCode: LanguageCode) async throws -> GenreList
}

final actor GenresListFetcher: GenresListFetcherProtocol {
    private let movieDatabaseAPIClient: MovieDatabaseAPIClient
    private var cachedMovieGenresList: [LanguageCode: GenreList]
    private var cachedTvShowGenresList: [LanguageCode: GenreList]

    init(
        movieDatabaseAPIClient: MovieDatabaseAPIClient,
        cachedMovieGenresList: [LanguageCode: GenreList] = [:],
        cachedTvShowGenresList: [LanguageCode: GenreList] = [:]
    ) {
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
        self.cachedMovieGenresList = cachedMovieGenresList
        self.cachedTvShowGenresList = cachedTvShowGenresList
    }

    func fetchMovieGenresList(languageCode: LanguageCode) async throws -> GenreList {
        if let cached = cachedMovieGenresList[languageCode] {
            return cached
        } else {
            let genresList = try await movieDatabaseAPIClient.fetchMovieGenresList(language: languageCode)
            cachedMovieGenresList[languageCode] = genresList
            return genresList
        }
    }

    func fetchTvShowGenresList(languageCode: LanguageCode) async throws -> GenreList {
        if let cached = cachedTvShowGenresList[languageCode] {
            return cached
        } else {
            let genresList = try await movieDatabaseAPIClient.fetchTVShowGenresList(language: languageCode)
            cachedTvShowGenresList[languageCode] = genresList
            return genresList
        }
    }
}
