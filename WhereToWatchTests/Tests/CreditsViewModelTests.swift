@testable import WhereToWatch
import MovieDatabaseAPI
import XCTest

final class CreditsViewModelTests: XCTestCase {
    var sut: CreditsViewModel!
    var movieDatabaseAPIClient: MockMovieDatabaseAPIClient!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        movieDatabaseAPIClient = MockMovieDatabaseAPIClient()
        sut = CreditsViewModel(movieDatabaseAPIClient: movieDatabaseAPIClient)
    }

    override func tearDownWithError() throws {
        sut = nil
        movieDatabaseAPIClient = nil
        try super.tearDownWithError()
    }

    func testFetchMovieCredits() async throws {
        // given
        movieDatabaseAPIClient.movieCreditsResult = PreviewData.creditsData.cast

        // when
        try await sut.fetchMovieCredits(movieID: 0)

        // then
        await MainActor.run {
            XCTAssertEqual(sut.creditItems[0].id, PreviewData.creditsData.cast[0].id)
            XCTAssertEqual(sut.creditItems.count, PreviewData.creditsData.cast.count)
        }
    }

    func testFetchMovieCreditsWithError() async {
        // given
        movieDatabaseAPIClient.movieCreditsError =  MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchMovieCredits(movieID: 0)
            XCTFail("Should return MovieDatabaseAPIError.badStatus")
        } catch {
            if let error = error as? MovieDatabaseAPIError, case .badStatus = error {
                // then
            } else {
                XCTFail("Should return MovieDatabaseAPIError.badStatus")
            }
        }
    }

    func testFetchTVShowCredits() async throws {
        // given
        movieDatabaseAPIClient.tvShowCreditsResult = PreviewData.creditsData.cast

        // when
        try await sut.fetchTVShowCredits(tvShowID: 0)

        // then
        await MainActor.run {
            XCTAssertEqual(sut.creditItems[0].id, PreviewData.creditsData.cast[0].id)
            XCTAssertEqual(sut.creditItems.count, PreviewData.creditsData.cast.count)
        }
    }

    func testFetchTVShowCreditsWithError() async {
        // given
        movieDatabaseAPIClient.tvShowCreditsError =  MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchTVShowCredits(tvShowID: 0)
            XCTFail("Should return MovieDatabaseAPIError.badStatus")
        } catch {
            if let error = error as? MovieDatabaseAPIError, case .badStatus = error {
                // then
            } else {
                XCTFail("Should return MovieDatabaseAPIError.badStatus")
            }
        }
    }
}
