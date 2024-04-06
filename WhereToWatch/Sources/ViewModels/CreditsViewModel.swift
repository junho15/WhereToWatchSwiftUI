import SwiftUI
import MovieDatabaseAPI

@MainActor
final class CreditsViewModel: ObservableObject, LocaleRepresentable {

    // MARK: Properties

    @Published var creditItems: [CreditItem]

    private let movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol

    // MARK: Lifecycle

    init(movieDatabaseAPIClient: MovieDatabaseAPIClientProtocol, creditItems: [CreditItem] = []) {
        self.creditItems = creditItems
        self.movieDatabaseAPIClient = movieDatabaseAPIClient
    }
}

// MARK: - Methods

extension CreditsViewModel {
    func fetchMovieCredits(movieID: Movie.ID) async throws {
        guard let languageCountryCode else { return }

        let fetchedMovieCredits = try await movieDatabaseAPIClient.fetchMovieCredits(
            movieID: movieID, language: languageCountryCode
        )

        self.creditItems = fetchedMovieCredits.map { credit in
            CreditItem(credit: credit)
        }
    }

    func fetchTVShowCredits(tvShowID: TVShow.ID) async throws {
        guard let languageCountryCode else { return }

        let fetchedTVShowCredits = try await movieDatabaseAPIClient.fetchTVShowCredits(
            tvShowID: tvShowID, language: languageCountryCode
        )

        self.creditItems = fetchedTVShowCredits.map { credit in
            CreditItem(credit: credit)
        }
    }
}
