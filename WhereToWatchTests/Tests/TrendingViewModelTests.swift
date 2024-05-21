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

    func testFetchTrendingMediaItems() async throws {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.tvShowGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.trendingMoviesResult = PreviewData.moviePageData
        movieDatabaseAPIClient.trendingTVShowsResult = PreviewData.tvShowPageData

        // when
        try await sut.fetchTrendingMediaItems()

        // then
        await MainActor.run {
            XCTAssertEqual(sut.movieMediaItems[0].id, PreviewData.moviePageData.results[0].id)
            XCTAssertEqual(sut.movieMediaItems.count, PreviewData.moviePageData.results.count)
            XCTAssertEqual(sut.tvShowMediaItems[0].id, PreviewData.tvShowPageData.results[0].id)
            XCTAssertEqual(sut.tvShowMediaItems.count, PreviewData.tvShowPageData.results.count)
        }
    }

    func testFetchTrendingMediaItemsWithError() async {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.tvShowGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.trendingMoviesError = MovieDatabaseAPIError.badStatus
        movieDatabaseAPIClient.trendingTVShowsError = MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchTrendingMediaItems()
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
