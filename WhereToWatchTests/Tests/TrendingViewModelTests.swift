@testable import WhereToWatch
import MovieDatabaseAPI
import XCTest

final class TrendingViewModelTests: XCTestCase {
    var sut: TrendingViewModel!
    var movieDatabaseAPIClient: MockMovieDatabaseAPIClient!
    var genresListFetcher: GenresListFetcher!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        movieDatabaseAPIClient = MockMovieDatabaseAPIClient()
        genresListFetcher = GenresListFetcher(movieDatabaseAPIClient: movieDatabaseAPIClient)
        sut = TrendingViewModel(movieDatabaseAPIClient: movieDatabaseAPIClient, genresListFetcher: genresListFetcher)
    }

    override func tearDownWithError() throws {
        sut = nil
        genresListFetcher = nil
        movieDatabaseAPIClient = nil
        try super.tearDownWithError()
    }

    func testFetchTrendingMovies() async throws {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.trendingMoviesResult = PreviewData.moviePageData

        // when
        try await sut.fetchTrendingMovies(of: .day)

        // then
        await MainActor.run {
            XCTAssertEqual(sut.movieMediaItems[0].id, PreviewData.moviePageData.results[0].id)
            XCTAssertEqual(sut.movieMediaItems.count, PreviewData.moviePageData.results.count)
        }
    }

    func testFetchTrendingMoviesWithError() async {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.trendingMoviesError = MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchTrendingMovies(of: .day)
            XCTFail("Should return MovieDatabaseAPIError.badStatus")
        } catch {
            if let error = error as? MovieDatabaseAPIError, case .badStatus = error {
                // then
            } else {
                XCTFail("Should return MovieDatabaseAPIError.badStatus")
            }
        }
    }

    func testFetchTrendingTVShows() async throws {
        // given
        movieDatabaseAPIClient.tvShowGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.trendingTVShowsResult = PreviewData.tvShowPageData

        // when
        try await sut.fetchTrendingTVShows(of: .day)

        // then
        await MainActor.run {
            XCTAssertEqual(sut.tvShowMediaItems[0].id, PreviewData.tvShowPageData.results[0].id)
            XCTAssertEqual(sut.tvShowMediaItems.count, PreviewData.tvShowPageData.results.count)
        }
    }

    func testFetchTrendingTVShowsWithError() async {
        // given
        movieDatabaseAPIClient.tvShowGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.trendingTVShowsError = MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchTrendingTVShows(of: .day)
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
