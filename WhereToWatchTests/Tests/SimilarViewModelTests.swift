@testable import WhereToWatch
import MovieDatabaseAPI
import XCTest

final class SimilarViewModelTests: XCTestCase {
    var sut: SimilarViewModel!
    var movieDatabaseAPIClient: MockMovieDatabaseAPIClient!
    var genresListFetcher: GenresListFetcher!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        movieDatabaseAPIClient = MockMovieDatabaseAPIClient()
        genresListFetcher = GenresListFetcher(movieDatabaseAPIClient: movieDatabaseAPIClient)
        let mediaItem = MediaItem(
            id: 1, mediaType: .movie, posterPath: nil, backdropPath: nil,
            title: nil, genre: nil, year: nil, overview: nil
        )
        sut = SimilarViewModel(
            mediaItem: mediaItem, movieDatabaseAPIClient: movieDatabaseAPIClient, genresListFetcher: genresListFetcher
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        genresListFetcher = nil
        movieDatabaseAPIClient = nil
        try super.tearDownWithError()
    }

    func testFetchSimilarMedia() async throws {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.similarMoviesResult = PreviewData.similarMovieData

        // when
        try await sut.fetchSimilarMedia()

        // then
        await MainActor.run {
            XCTAssertEqual(sut.similarMediaItem[0].id, PreviewData.similarMovieData.results[0].id)
            XCTAssertEqual(sut.similarMediaItem.count, PreviewData.similarMovieData.results.count)
        }
    }

    func testFetchSimilarMediaWithError() async {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.similarMoviesError = MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchSimilarMedia()
            XCTFail("Should return MovieDatabaseAPIError.badStatus")
        } catch {
            if let error = error as? MovieDatabaseAPIError, case .badStatus = error {
                // then
            } else {
                XCTFail("Should return MovieDatabaseAPIError.badStatus")
            }
        }
    }

    func testFetchMoreSimilarMedia() async throws {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.similarMoviesResult = PreviewData.similarMovieData

        // when
        try await sut.fetchMoreSimilarMedia()

        // then
        await MainActor.run {
            XCTAssertEqual(sut.similarMediaItem[0].id, PreviewData.similarMovieData.results[0].id)
            XCTAssertEqual(sut.similarMediaItem.count, PreviewData.similarMovieData.results.count)
        }
    }

    func testFetchMoreSimilarMediaWithError() async {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.similarMoviesError = MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchMoreSimilarMedia()
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
