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

    func testFetchCredits() async throws {
        // given
        movieDatabaseAPIClient.movieCreditsResult = PreviewData.creditsData.cast

        // when
        try await sut.fetchCredits(for: PreviewData.mediaItem)

        // then
        await MainActor.run {
            XCTAssertEqual(sut.creditItems[0].id, PreviewData.creditsData.cast[0].id)
            XCTAssertEqual(sut.creditItems.count, PreviewData.creditsData.cast.count)
        }
    }

    func testFetchCreditsWithError() async {
        // given
        movieDatabaseAPIClient.movieCreditsError =  MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchCredits(for: PreviewData.mediaItem)
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
