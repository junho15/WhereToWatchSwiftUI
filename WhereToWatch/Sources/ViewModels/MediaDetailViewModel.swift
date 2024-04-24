import SwiftUI
import Combine
import MovieDatabaseAPI

@MainActor
final class MediaDetailViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var isFavorite: Bool

    let mediaItem: MediaItem

    private let favoriteService: FavoriteServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifecycle

    init(
        isFavorite: Bool,
        mediaItem: MediaItem,
        favoriteService: FavoriteServiceProtocol
    ) {
        self.isFavorite = isFavorite
        self.mediaItem = mediaItem
        self.favoriteService = favoriteService

        setUpFavoriteStatus()
    }
}

// MARK: - Methods

private extension MediaDetailViewModel {
    func setUpFavoriteStatus() {
        $isFavorite
            .dropFirst()
            .sink { [weak self] newFavoriteStatus in
                guard let self else { return }

                do {
                    if newFavoriteStatus {
                        try favoriteService.add(FavoriteMediaItem(mediaItem: mediaItem))
                    } else {
                        try favoriteService.remove(mediaItem.id)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
}
