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
    func testFetchFavorites() async throws {
        // given
        movieDatabaseAPIClient.movieGenresListResult = TestData.movieGenreList
        movieDatabaseAPIClient.movieDetailResult = TestData.movieDetailData
        favoriteService.favorites = [TestData.favoriteMediaItem]

        // when
        try await sut.fetchFavorites(sortOption: .registrationDate)

        // then
        XCTAssertEqual(sut.mediaItems[0].id, TestData.mediaItems[0].id)
    }

    @MainActor
    func testFetchFavoritesWithError() async {
        // given
        favoriteService.shouldReturnError = true

        // when
        do {
            try await sut.fetchFavorites(sortOption: .registrationDate)
            XCTFail("Should return error")
        } catch {
            // then
        }
    }

    @MainActor
    func testSortOptionChanging() async {
        // given
        movieDatabaseAPIClient.movieGenresListResult = TestData.movieGenreList
        movieDatabaseAPIClient.movieDetailResult = TestData.movieDetailData
        favoriteService.favorites = [TestData.favoriteMediaItem]
        let sortOption = FavoritesSortOption.reverseRegistrationDate

        // when
        sut.sortOption = sortOption

        // then
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        XCTAssertEqual(self.favoriteService.sortOption, sortOption)
    }

    @MainActor
    func testFavoriteDeleting() async {
        // given
        favoriteService.favorites = TestData.favorites
        sut.mediaItems = TestData.mediaItems
        let firstItem = TestData.mediaItems[0]

        // when
        sut.mediaItems.removeFirst()

        // then
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        XCTAssertNotEqual(self.sut.mediaItems[0].id, firstItem.id)
        XCTAssertNotEqual(self.favoriteService.favorites[0].id, firstItem.id)
    }
}

private extension FavoritesViewModelTests {
    enum TestData {
        static let movies = PreviewData.moviePageData.results
        static let movieGenreList = PreviewData.genreListData
        static let movieDetailData = PreviewData.movieDetailData
        static let favoriteMediaItem = {
            return FavoriteMediaItem(mediaItem: MediaItem(media: movieDetailData, genreList: movieGenreList))
        }()
        static let mediaItems = movies.map { movie in
            MediaItem(media: movie, genreList: movieGenreList)
        }
        static let favorites = mediaItems.map { mediaItem in
            FavoriteMediaItem(mediaItem: mediaItem)
        }
    }
}
