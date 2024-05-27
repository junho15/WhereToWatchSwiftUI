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
        try await sut.fetchFavorites()

        // then
        XCTAssertEqual(sut.mediaItems[0].id, TestData.mediaItems[0].id)
    }

    @MainActor
    func testFetchFavoritesWithError() async {
        // given
        favoriteService.shouldReturnError = true

        // when
        do {
            try await sut.fetchFavorites()
            XCTFail("Should return error")
        } catch {
            // then
        }
    }

    @MainActor
    func testSortOptionChanging() async {
        // given
        let mediaItems = TestData.mediaItems
        let sortOption = FavoritesSortOption.title
        let sortedItems = TestData.mediaItems.sorted(by: sortOption.comparator)

        sut = FavoritesViewModel(
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            favoriteService: favoriteService,
            mediaItems: mediaItems
        )

        // when
        sut.sortOption = sortOption

        // then
        XCTAssertNotEqual(sut.mediaItems, mediaItems)
        XCTAssertEqual(sut.mediaItems, sortedItems)
    }

    @MainActor
    func testSearchText() async {
        // given
        let mediaItems = TestData.mediaItems
        let searchText = "토르"
        let filteredItems = TestData.mediaItems.filter { mediaItem in
            mediaItem.title?.localizedCaseInsensitiveContains(searchText) ?? false
        }
        sut = FavoritesViewModel(
            movieDatabaseAPIClient: movieDatabaseAPIClient,
            genresListFetcher: genresListFetcher,
            favoriteService: favoriteService,
            mediaItems: mediaItems
        )

        // when
        sut.searchText = searchText

        // then
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        XCTAssertNotEqual(sut.mediaItems.count, mediaItems.count)
        XCTAssertEqual(sut.mediaItems.count, filteredItems.count)
    }

    @MainActor
    func testFavoriteDeleting() async {
        // given
        favoriteService.favorites = TestData.favorites
        sut.mediaItems = TestData.mediaItems

        // when
        sut.deleteMediaItem(at: IndexSet(integer: 0))

        // then
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        XCTAssertNotEqual(self.sut.mediaItems.count, TestData.mediaItems.count)
        XCTAssertNotEqual(self.favoriteService.favorites.count, TestData.mediaItems.count)
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
