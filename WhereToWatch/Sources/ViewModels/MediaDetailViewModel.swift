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

    init(mediaItem: MediaItem, favoriteService: FavoriteServiceProtocol) async {
        self.isFavorite = await (try? favoriteService.contains(mediaItem.id)) ?? false
        self.mediaItem = mediaItem
        self.favoriteService = favoriteService

        setUpFavoriteStatus()
    }
}

// MARK: - Methods

private extension MediaDetailViewModel {
    func setUpFavoriteStatus() {
        $isFavorite
            .sink { [weak self] newFavoriteStatus in
                Task { [weak self] in
                    guard let self else { return }

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
