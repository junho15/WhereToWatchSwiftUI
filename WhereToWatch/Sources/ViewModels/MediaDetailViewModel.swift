import SwiftUI
import Combine
import MovieDatabaseAPI

@MainActor
final class MediaDetailViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var isFavorite: Bool?

    let mediaItem: MediaItem

    private let favoriteService: FavoriteServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifecycle

    init(mediaItem: MediaItem, favoriteService: FavoriteServiceProtocol) {
        self.mediaItem = mediaItem
        self.favoriteService = favoriteService

        Task {
            do {
                self.isFavorite = try await favoriteService.contains(mediaItem.id)
            } catch {
                // Handle error
            }
            setUpFavoriteStatus()
        }
    }
}

// MARK: - Methods

private extension MediaDetailViewModel {
    func setUpFavoriteStatus() {
        $isFavorite
            .dropFirst()
            .sink { [weak self] newFavoriteStatus in
                Task { [weak self] in
                    guard let self, let newFavoriteStatus else { return }

                    do {
                        if newFavoriteStatus {
                            try await favoriteService.add(FavoriteMediaItem(mediaItem: mediaItem))
                        } else {
                            try await favoriteService.remove(mediaItem.id)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
