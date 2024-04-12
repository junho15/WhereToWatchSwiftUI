@testable import WhereToWatch
import MovieDatabaseAPI
import XCTest
import Combine

final class SearchViewModelTests: XCTestCase {
    var sut: SearchViewModel!
    var movieDatabaseAPIClient: MockMovieDatabaseAPIClient!
    var genresListFetcher: GenresListFetcher!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []
        movieDatabaseAPIClient = MockMovieDatabaseAPIClient()
        genresListFetcher = GenresListFetcher(movieDatabaseAPIClient: movieDatabaseAPIClient)
        sut = SearchViewModel(movieDatabaseAPIClient: movieDatabaseAPIClient, genresListFetcher: genresListFetcher)
    }

    override func tearDownWithError() throws {
        sut = nil
        genresListFetcher = nil
        movieDatabaseAPIClient = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    func testFetchMoreMovies() async throws {
        // given
        let query = "test"
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.searchMoviesResult = PreviewData.moviePageData

        // when
        try await sut.fetchMoreMovies()

        // then
        await MainActor.run {
            XCTAssertEqual(sut.movieMediaItems[0].id, PreviewData.moviePageData.results[0].id)
            XCTAssertEqual(sut.movieMediaItems.count, PreviewData.moviePageData.results.count)
        }
    }

    func testFetchMoreMoviesWithError() async {
        // given
        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.searchMoviesError = MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchMoreMovies()
            XCTFail("Should return MovieDatabaseAPIError.badStatus")
        } catch {
            if let error = error as? MovieDatabaseAPIError, case .badStatus = error {
                // then
            } else {
                XCTFail("Should return MovieDatabaseAPIError.badStatus")
            }
        }
    }

    func testFetchMoreTVShows() async throws {
        // given
        let query = "test"
        movieDatabaseAPIClient.tvShowGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.searchTVShowsResult = PreviewData.tvShowPageData

        // when
        try await sut.fetchMoreTVShows()

        // then
        await MainActor.run {
            XCTAssertEqual(sut.tvShowMediaItems[0].id, PreviewData.tvShowPageData.results[0].id)
            XCTAssertEqual(sut.tvShowMediaItems.count, PreviewData.tvShowPageData.results.count)
        }

    }

    func testFetchMoreTVShowsWithError() async {
        // given
        movieDatabaseAPIClient.tvShowGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.searchTVShowsError = MovieDatabaseAPIError.badStatus

        // when
        do {
            try await sut.fetchMoreTVShows()
            XCTFail("Should return MovieDatabaseAPIError.badStatus")
        } catch {
            if let error = error as? MovieDatabaseAPIError, case .badStatus = error {
                // then
            } else {
                XCTFail("Should return MovieDatabaseAPIError.badStatus")
            }
        }
    }

    @MainActor
    func testSearchTextDebouncing() {
        // given
        let sut = sut!
        let expectation = XCTestExpectation(description: "Debouncing of searchText")

        movieDatabaseAPIClient.movieGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.tvShowGenresListResult = PreviewData.genreListData
        movieDatabaseAPIClient.searchMoviesResult = PreviewData.moviePageData
        movieDatabaseAPIClient.searchTVShowsResult = PreviewData.tvShowPageData

        // when
        sut.$searchText
            .dropFirst()
            .sink { _ in
                // then
                XCTAssertEqual(sut.searchText, "test4")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        Task {
            for text in ["test1", "test2", "test3", "test4"] {
                sut.searchText = text
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }

            await fulfillment(of: [expectation], timeout: 2)
        }
    }

    @MainActor
    func testIgnoringDuplicateSearchText() {
        // given
        let sut = sut!
        let expectation = XCTestExpectation(description: "Ignoring duplicate searchText")
        var outputCount = 0

        // when
        sut.$searchText
            .sink { _ in
                outputCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)

        Task {
            sut.searchText = "test"
            sut.searchText = "test"
            sut.searchText = "test2"

            try? await Task.sleep(nanoseconds: 1_000_000_000)

            // then
            XCTAssertEqual(outputCount, 2)

            await fulfillment(of: [expectation], timeout: 3.5)
        }
    }
}
