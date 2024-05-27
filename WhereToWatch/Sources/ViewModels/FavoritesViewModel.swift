import SwiftUI
import Combine
import MovieDatabaseAPI

@MainActor
final class FavoritesViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var mediaItems: [MediaItem]
    @Published var sortOption: FavoritesSortOption
    @Published var searchText: String

    private let movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol
    private let genresListFetcher: GenresListFetcherProtocol
    private let favoriteService: FavoriteServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var fetchedMediaItems: [MediaItem]

    // MARK: Lifecycle

    init(
        movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol,
        genresListFetcher: GenresListFetcherProtocol,
        favoriteService: FavoriteServiceProtocol,
        mediaItems: [MediaItem] = [],
        sortOption: FavoritesSortOption = .registrationDate,
        searchText: String = ""
    ) {
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
        self.genresListFetcher = genresListFetcher
        self.favoriteService = favoriteService
        self.mediaItems = mediaItems
        self.fetchedMediaItems = mediaItems
        self.sortOption = sortOption
        self.searchText = searchText

        setUpSortOption()
        setUpSearchQuery()
    }
}

// MARK: - Methods

extension FavoritesViewModel {
    func fetchFavorites() async throws {
        let favoriteMediaItems = try await favoriteService.fetch(offset: nil, limit: nil)
        fetchedMediaItems = try await mediaItems(for: favoriteMediaItems)
        applyFilters(to: fetchedMediaItems)
    }

    func deleteMediaItem(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let mediaItem = mediaItems[index]
            Task {
                do {
                    try await remove(mediaItem.id)
                    mediaItems.remove(at: index)
                    fetchedMediaItems.removeAll(where: { $0.id == mediaItem.id })
                } catch {
                    // Handle error
                }
            }
        }
    }
}

private extension FavoritesViewModel {
    func setUpSortOption() {
        $sortOption
            .dropFirst()
            .sink { [weak self] sortOption in
                guard let self else { return }
                self.applyFilters(sortOption: sortOption)
            }
            .store(in: &cancellables)
    }

    func setUpSearchQuery() {
        $searchText
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] searchText in
                guard let self else { return }
                self.applyFilters(searchText: searchText)
            })
            .store(in: &cancellables)
    }

    func mediaItems(for favoriteMediaItems: [FavoriteMediaItem]) async throws -> [MediaItem] {
        var results = [MediaItem?](repeating: nil, count: favoriteMediaItems.count)

        try await withThrowingTaskGroup(of: (Int, MediaItem?).self) { group in
            favoriteMediaItems.enumerated().forEach { index, favoriteMediaItem in
                group.addTask {
                    let mediaItem = try await self.mediaItem(for: favoriteMediaItem)
                    return (index, mediaItem)
                }
            }

            for try await (index, mediaItem) in group {
                results[index] = mediaItem
            }
        }

        return results.compactMap { $0 }
    }

    func mediaItem(for favoriteMediaItem: FavoriteMediaItem) async throws -> MediaItem {
        guard let languageCode, let languageCountryCode else {
            throw MovieDatabaseAPIError.emptyData
        }

        switch favoriteMediaItem.mediaType {
        case .movie:
            let movieGenresList = try await self.genresListFetcher.fetchMovieGenresList(
                languageCode: languageCode
            )
            let movie = try await self.movieDatabaseAPIClient.fetchMovieDetail(
                movieID: favoriteMediaItem.id, language: languageCountryCode
            )
            return MediaItem(
                media: movie, genreList: movieGenresList, favoriteRegistrationDate: favoriteMediaItem.registrationDate
            )
        case .tvShow:
            let tvShowGenresList = try await self.genresListFetcher.fetchTVShowGenresList(
                languageCode: languageCode
            )
            let tvShow = try await self.movieDatabaseAPIClient.fetchTVShowDetail(
                tvShowID: favoriteMediaItem.id, language: languageCountryCode
            )
            return MediaItem(
                media: tvShow, genreList: tvShowGenresList, favoriteRegistrationDate: favoriteMediaItem.registrationDate
            )
        }
    }

    func remove(_ id: MediaItem.ID) async throws {
        try await favoriteService.remove(id)
    }

    func applyFilters(
        to items: [MediaItem]? = nil,
        searchText: String? = nil,
        sortOption: FavoritesSortOption? = nil
    ) {
        let filteredItems = (items ?? fetchedMediaItems).filter { mediaItem in
            let searchText = (searchText ?? self.searchText)
            guard searchText.isEmpty == false else { return true }
            guard let title = mediaItem.title else { return false }
            return title.localizedCaseInsensitiveContains(searchText)
        }

        let sortOption = (sortOption ?? self.sortOption)
        let sortedItems = filteredItems.sorted(by: sortOption.comparator)

        mediaItems = sortedItems
    }
}
