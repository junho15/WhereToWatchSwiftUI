import SwiftUI
import Combine
import MovieDatabaseAPI

@MainActor
final class SearchViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var searchText: String
    @Published var movieMediaItems: [MediaItem]
    @Published var tvShowMediaItems: [MediaItem]

    private let movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol
    private let genresListFetcher: GenresListFetcherProtocol
    private var movieLastPage: Int
    private var tvShowLastPage: Int
    private var movieTotalPage: Int
    private var tvShowTotalPage: Int

    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifecycle

    init(
        movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol,
        genresListFetcher: GenresListFetcherProtocol,
        searchText: String = "",
        movieMediaItems: [MediaItem] = [],
        tvShowMediaItems: [MediaItem] = [],
        movieLastPage: Int = 0,
        movieTotalPage: Int = 1,
        tvShowLastPage: Int = 0,
        tvShowTotalPage: Int = 1
    ) {
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
        self.genresListFetcher = genresListFetcher
        self.searchText = searchText
        self.movieMediaItems = movieMediaItems
        self.tvShowMediaItems = tvShowMediaItems
        self.movieLastPage = movieLastPage
        self.movieTotalPage = movieTotalPage
        self.tvShowLastPage = tvShowLastPage
        self.tvShowTotalPage = tvShowTotalPage

        setUpSearch()
    }
}

// MARK: - Methods

extension SearchViewModel {
    func fetchMoreMovies() async throws {
        guard movieLastPage < movieTotalPage else { return }

        try await searchMovies(query: searchText, page: movieLastPage + 1)
    }

    func fetchMoreTVShows() async throws {
        guard tvShowLastPage < tvShowTotalPage else { return }

        try await searchTVShows(query: searchText, page: tvShowLastPage + 1)
    }

    private func setUpSearch() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { searchText in
                Task { [weak self] in
                    guard let self, searchText.isEmpty == false else { return }

                    do {
                        try await searchMovies(query: searchText, page: 1)
                        try await searchTVShows(query: searchText, page: 1)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            })
            .store(in: &cancellables)
    }

    private func searchMovies(query: String, page: Int) async throws {
        guard let languageCode = languageCode else { return }

        let genresList = try await genresListFetcher.fetchMovieGenresList(languageCode: languageCode)
        let result = try await movieDatabaseAPIClient.searchMovies(
            query: query, language: languageCountryCode, page: page,
            includeAdult: nil, region: nil, year: nil, primaryReleaseYear: nil
        )
        let mediaItems = result.results.map { movie in
            MediaItem(media: movie, genreList: genresList)
        }

        self.movieLastPage = result.page
        self.movieTotalPage = result.totalPages
        if result.page == 1 {
            self.movieMediaItems = mediaItems
        } else {
            self.movieMediaItems += mediaItems
        }
    }

    private func searchTVShows(query: String, page: Int) async throws {
        guard let languageCode = languageCode else { return }

        let genresList = try await genresListFetcher.fetchTVShowGenresList(languageCode: languageCode)
        let result = try await movieDatabaseAPIClient.searchTVShows(
            query: query, language: languageCountryCode, page: page,
            includeAdult: nil, firstAirDateYear: nil
        )
        let mediaItems = result.results.map { tvShow in
            MediaItem(media: tvShow, genreList: genresList)
        }

        self.tvShowLastPage = result.page
        self.tvShowTotalPage = result.totalPages
        if result.page == 1 {
            self.tvShowMediaItems = mediaItems
        } else {
            self.tvShowMediaItems += mediaItems
        }
    }
}
