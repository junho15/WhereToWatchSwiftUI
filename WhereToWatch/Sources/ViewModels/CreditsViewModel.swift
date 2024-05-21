import SwiftUI
import MovieDatabaseAPI

@MainActor
final class CreditsViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var creditItems: [CreditItem]

    private let mediaItem: MediaItem
    private let movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol

    // MARK: Lifecycle

    init(
        mediaItem: MediaItem, movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol, creditItems: [CreditItem] = []
    ) {
        self.mediaItem = mediaItem
        self.creditItems = creditItems
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
    }
}

// MARK: - Methods

extension CreditsViewModel {
    func fetchCredits() async throws {
        switch mediaItem.mediaType {
        case .movie:
            try await fetchMovieCredits(movieID: mediaItem.id)
        case .tvShow:
            try await fetchTVShowCredits(tvShowID: mediaItem.id)
        }
    }

    private func fetchMovieCredits(movieID: Movie.ID) async throws {
        guard let languageCountryCode else { return }

        let fetchedMovieCredits = try await movieDatabaseAPIClient.fetchMovieCredits(
            movieID: movieID, language: languageCountryCode
        )

        self.creditItems = fetchedMovieCredits.map { credit in
            CreditItem(credit: credit)
        }
    }

    private func fetchTVShowCredits(tvShowID: TVShow.ID) async throws {
        guard let languageCountryCode else { return }

        let fetchedTVShowCredits = try await movieDatabaseAPIClient.fetchTVShowCredits(
            tvShowID: tvShowID, language: languageCountryCode
        )

        self.creditItems = fetchedTVShowCredits.map { credit in
            CreditItem(credit: credit)
        }
    }
}
