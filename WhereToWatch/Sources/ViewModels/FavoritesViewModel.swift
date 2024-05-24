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
        self.sortOption = sortOption
        self.searchText = searchText

        setUpSortOption()
        setUpSearchQuery()
        setUpFavoritesObserve()
    }
}

// MARK: - Methods

extension FavoritesViewModel {
    func fetchFavorites() async throws {
        let favoriteMediaItems = try await favoriteService.fetch(offset: nil, limit: nil)
        let fetchedMediaItems = try await mediaItems(for: favoriteMediaItems)
        applyFilters(to: fetchedMediaItems)
    }
}

private extension FavoritesViewModel {
    func setUpSortOption() {
        $sortOption
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }
                self.applyFilters()
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
            }, receiveValue: { [weak self] _ in
                guard let self else { return }
                self.applyFilters()
            })
            .store(in: &cancellables)
    }

    func setUpFavoritesObserve() {
        $mediaItems
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] items in
                guard let self else { return }
                guard items.count < self.mediaItems.count else { return }

                let currentIDs = Set(items.map { $0.id })
                let previousIDs = Set(self.mediaItems.map { $0.id })

                let deletedIDs = previousIDs.subtracting(currentIDs)
                guard deletedIDs.isEmpty == false else { return }
                deletedIDs.forEach { id in
                    Task { [weak self] in
                        guard let self else { return }
                        do {
                            try await self.remove(id)
                        } catch {
                            // Handle error
                        }
                    }
                }
            }
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
            return MediaItem(media: movie, genreList: movieGenresList)
        case .tvShow:
            let tvShowGenresList = try await self.genresListFetcher.fetchTVShowGenresList(
                languageCode: languageCode
            )
            let tvShow = try await self.movieDatabaseAPIClient.fetchTVShowDetail(
                tvShowID: favoriteMediaItem.id, language: languageCountryCode
            )
            return MediaItem(media: tvShow, genreList: tvShowGenresList)
        }
    }

    func remove(_ id: MediaItem.ID) async throws {
        try await favoriteService.remove(id)
    }

    func applyFilters(to items: [MediaItem]? = nil) {
        let filteredItems = (items ?? mediaItems).filter { mediaItem in
            guard searchText.isEmpty == false else { return true }
            guard let title = mediaItem.title else { return false }
            return title.localizedCaseInsensitiveContains(searchText)
        }

        let sortedItems = filteredItems.sorted(by: sortOption.comparator)

        mediaItems = sortedItems
    }
}
