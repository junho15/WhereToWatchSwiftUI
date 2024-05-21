import SwiftUI
import Combine
import MovieDatabaseAPI

@MainActor
final class FavoritesViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var mediaItems: [MediaItem]
    @Published var sortOption: FavoritesSortOption

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
        sortOption: FavoritesSortOption = .registrationDate
    ) {
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
        self.genresListFetcher = genresListFetcher
        self.favoriteService = favoriteService
        self.mediaItems = mediaItems
        self.sortOption = sortOption

        setUpSortOption()
        setUpFavoritesObserve()
    }
}

// MARK: - Methods

extension FavoritesViewModel {
    func fetchFavorites(sortOption: FavoritesSortOption) async throws {
        let favoriteMediaItems = try await favoriteService.fetch(sortOption: sortOption, offset: nil, limit: nil)
        mediaItems = try await mediaItems(for: favoriteMediaItems)
    }
}

private extension FavoritesViewModel {
    func setUpSortOption() {
        $sortOption
            .dropFirst()
            .sink { [weak self] sortOption in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        try await self.fetchFavorites(sortOption: sortOption)
                    } catch {
                        // Handle error
                    }
                }
            }
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
}
