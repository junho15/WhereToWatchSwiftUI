@testable import WhereToWatch
import MovieDatabaseAPI
import XCTest

final class GenresListFetcherTests: XCTestCase {
    var sut: GenresListFetcher!
    var movieDatabaseAPIClient: MockMovieDatabaseAPIClient!

    override func setUpWithError() throws {
        try super.setUpWithError()
        movieDatabaseAPIClient = MockMovieDatabaseAPIClient()
        sut = GenresListFetcher(movieDatabaseAPIClient: movieDatabaseAPIClient)
    }

    override func tearDownWithError() throws {
        sut = nil
        movieDatabaseAPIClient = nil
        try super.tearDownWithError()
    }

    func testFetchMovieGenresList() async throws {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData

        // when
        let result = try await sut.fetchMovieGenresList(languageCode: "Test")

        // then
        XCTAssertEqual(result.genres[0].id, PreviewData.genreListData.genres[0].id)
    }

    func testFetchMovieGenresListWithError() async {
        // given
        movieDatabaseAPIClient.movieGenresListError = MovieDatabaseAPIError.badStatus

        // when
        do {
            _ = try await sut.fetchMovieGenresList(languageCode: "Test")
            XCTFail("Should return MovieDatabaseAPIError.badStatus")
        } catch {
            if let error = error as? MovieDatabaseAPIError, case .badStatus = error {
                // then
            } else {
                XCTFail("Should return MovieDatabaseAPIError.badStatus")
            }
        }
    }

    func testFetchTvShowGenresList() async throws {
        // given
        movieDatabaseAPIClient.tvShowGenresListResult = PreviewData.genreListData

        // when
        let result = try await sut.fetchTvShowGenresList(languageCode: "Test")

        // then
        XCTAssertEqual(result.genres[0].id, PreviewData.genreListData.genres[0].id)

    }

    func testFetchTvShowGenresListWithError() async {
        // given
        movieDatabaseAPIClient.tvShowGenresListError = MovieDatabaseAPIError.badStatus

        // when
        do {
            _ = try await sut.fetchTvShowGenresList(languageCode: "Test")
            XCTFail("Should return MovieDatabaseAPIError.badStatus")
        } catch {
            if let error = error as? MovieDatabaseAPIError, case .badStatus = error {
                // then
            } else {
                XCTFail("Should return MovieDatabaseAPIError.badStatus")
            }
        }    }
}
