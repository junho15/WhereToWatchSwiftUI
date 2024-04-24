import SwiftUI
import Combine
import MovieDatabaseAPI

@MainActor
final class FavoritesViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var favoriteMediaItems: [FavoriteMediaItem]
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
        favoriteMediaItems: [FavoriteMediaItem] = [],
        sortOption: FavoritesSortOption = .registrationDate
    ) {
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
        self.genresListFetcher = genresListFetcher
        self.favoriteService = favoriteService
        self.favoriteMediaItems = favoriteMediaItems
        self.sortOption = sortOption

        setUpSortOption()
        setUpFavoritesObserve()
    }
}

// MARK: - Methods

extension FavoritesViewModel {
    func fetchFavorites(sortOption: FavoritesSortOption) async throws {
        favoriteMediaItems = try await favoriteService.fetch(sortOption: sortOption, offset: nil, limit: nil)
    }

    func mediaItem(for id: FavoriteMediaItem.ID) async throws -> MediaItem {
        guard let languageCode, let languageCountryCode, let favoriteMediaItem = favoriteMediaItem(for: id) else {
            throw MovieDatabaseAPIError.emptyData
        }

        switch favoriteMediaItem.mediaType {
        case .movie:
            let movieGenresList = try await genresListFetcher.fetchMovieGenresList(languageCode: languageCode)
            let movie = try await movieDatabaseAPIClient.fetchMovieDetail(
                movieID: favoriteMediaItem.id, language: languageCountryCode
            )
            return MediaItem(media: movie, genreList: movieGenresList)
        case .tvShow:
            let tvShowGenresList = try await genresListFetcher.fetchTVShowGenresList(languageCode: languageCode)
            let tvShow = try await movieDatabaseAPIClient.fetchTVShowDetail(
                tvShowID: favoriteMediaItem.id, language: languageCountryCode
            )
            return MediaItem(media: tvShow, genreList: tvShowGenresList)
        }
    }
}

private extension FavoritesViewModel {
    func setUpSortOption() {
        $sortOption
            .dropFirst()
            .sink { [weak self] sortOption in
                Task { [weak self] in
                    guard let self else { return }
                    try? await self.fetchFavorites(sortOption: sortOption)
                }
            }
            .store(in: &cancellables)
    }

    func setUpFavoritesObserve() {
        $favoriteMediaItems
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] items in
                guard let self else { return }
                guard items.count < self.favoriteMediaItems.count else { return }

                let currentIDs = Set(items.map { $0.id })
                let previousIDs = Set(self.favoriteMediaItems.map { $0.id })

                let deletedIDs = previousIDs.subtracting(currentIDs)
                guard deletedIDs.isEmpty == false else { return }
                deletedIDs.forEach { id in
                    Task { [weak self] in
                        guard let self else { return }
                        try? await self.remove(id)
                    }
                }
            }
            .store(in: &cancellables)
    }

    func favoriteMediaItem(for id: FavoriteMediaItem.ID) -> FavoriteMediaItem? {
        return favoriteMediaItems.first(where: { $0.id == id })
    }

    func remove(_ id: FavoriteMediaItem.ID) async throws {
        try await favoriteService.remove(id)
    }
}
