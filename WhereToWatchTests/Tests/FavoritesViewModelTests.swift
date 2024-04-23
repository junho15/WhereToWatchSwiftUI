@testable import WhereToWatch
import MovieDatabaseAPI
import XCTest
import Combine

final class FavoritesViewModelTests: XCTestCase {
    var sut: FavoritesViewModel!
    var movieDatabaseAPIClient: MockMovieDatabaseAPIClient!
    var genresListFetcher: GenresListFetcher!
    var favoriteService: MockFavoriteService!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
        movieDatabaseAPIClient = MockMovieDatabaseAPIClient()
        genresListFetcher = GenresListFetcher(movieDatabaseAPIClient: movieDatabaseAPIClient)
        favoriteService = MockFavoriteService()
        sut = FavoritesViewModel(
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            favoriteService: favoriteService
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        favoriteService = nil
        genresListFetcher = nil
        movieDatabaseAPIClient = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    @MainActor
    func testFetchFavorites() throws {
        // given
        favoriteService.favorites = TestData.favorites

        // when
        XCTAssertNoThrow(try sut.fetchFavorites(sortOption: .registrationDate))

        // then
        XCTAssertEqual(sut.favoriteMediaItems[0].id, TestData.favorites[0].id)
        XCTAssertEqual(sut.favoriteMediaItems.count, TestData.favorites.count)
    }

    @MainActor
    func testFetchFavoritesWithError() {
        // given
        favoriteService.shouldReturnError = true

        // when, then
        XCTAssertThrowsError(try sut.fetchFavorites(sortOption: .registrationDate))
    }

    @MainActor
    func testMediaItem() async throws {
        // given
        let favoriteMediaItemID = TestData.favorites[0].id
        let mediaItem = TestData.movies[0]
        sut.favoriteMediaItems = TestData.favorites
        movieDatabaseAPIClient.movieGenresListResult = TestData.movieGenreList
        movieDatabaseAPIClient.movieDetailResult = TestData.movies[0]

        // when
        let result = try await sut.mediaItem(for: favoriteMediaItemID)

        // then
        XCTAssertEqual(result.id, mediaItem.id)
        XCTAssertEqual(result.mediaType, mediaItem.mediaType)
    }

    @MainActor
    func testMediaItemWithError() async {
        // given
        let favoriteMediaItemID = TestData.favorites[0].id
        sut.favoriteMediaItems = TestData.favorites
        movieDatabaseAPIClient.movieGenresListResult = TestData.movieGenreList
        movieDatabaseAPIClient.movieDetailError = MovieDatabaseAPIError.badStatus

        // when
        do {
            _ = try await sut.mediaItem(for: favoriteMediaItemID)
        } catch {
            if let error = error as? MovieDatabaseAPIError, case .badStatus = error {
                // then
            } else {
                XCTFail("Should return MovieDatabaseAPIError.badStatus")
            }
        }
    }

    @MainActor
    func testSortOptionChanging() async {
        // given
        favoriteService.favorites = TestData.favorites
        let sortOption = FavoritesSortOption.reverseRegistrationDate
        let expectation = XCTestExpectation(description: "Changing of SortOption")

        // when
        sut.$favoriteMediaItems
            .dropFirst()
            .sink { _ in
                // then
                XCTAssertEqual(self.favoriteService.sortOption, sortOption)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.sortOption = sortOption
        await fulfillment(of: [expectation], timeout: 1)
    }

    @MainActor
    func testFavoriteDeleting() {
        // given
        favoriteService.favorites = TestData.favorites
        sut.favoriteMediaItems = TestData.favorites
        let firstItem = TestData.favorites[0]

        // when
        sut.favoriteMediaItems.removeFirst()

        // then
        XCTAssertNotEqual(sut.favoriteMediaItems[0].id, firstItem.id)
        XCTAssertNotEqual(favoriteService.favorites[0].id, firstItem.id)
    }
}

private extension FavoritesViewModelTests {
    enum TestData {
        static let movies = PreviewData.moviePageData.results
        static let movieGenreList = PreviewData.genreListData
        static let favorites = movies.map { movie in
            FavoriteMediaItem(mediaItem: MediaItem(media: movie, genreList: movieGenreList))
        }
    }
}
