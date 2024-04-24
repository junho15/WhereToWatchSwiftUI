@testable import WhereToWatch
import MovieDatabaseAPI
import XCTest
import Combine

final class MediaDetailViewModelTests: XCTestCase {
    var sut: MediaDetailViewModel!
    var favoriteService: MockFavoriteService!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
        favoriteService = MockFavoriteService()
    }

    override func tearDownWithError() throws {
        sut = nil
        favoriteService = nil
        cancellables = nil

        try super.tearDownWithError()
    }

    @MainActor
    func testInitialFavoriteStatus() async {
        // given
        favoriteService.favorites = [FavoriteMediaItem(mediaItem: TestData.mediaItem)]

        // when
        sut = await MediaDetailViewModel(mediaItem: TestData.mediaItem, favoriteService: favoriteService)

        // then
        XCTAssertTrue(sut.isFavorite)
    }

    @MainActor
    func testAddingFavorite() async {
        // given
        favoriteService.favorites = []
        sut = await MediaDetailViewModel(mediaItem: TestData.mediaItem, favoriteService: favoriteService)

        // when
        sut.isFavorite = true

        // then
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        XCTAssertTrue(favoriteService.favorites.contains(where: { $0.id == TestData.mediaItem.id }))
    }

    @MainActor
    func testRemovingFavorite() async {
        // given
        favoriteService.favorites = [FavoriteMediaItem(mediaItem: TestData.mediaItem)]
        sut = await MediaDetailViewModel(mediaItem: TestData.mediaItem, favoriteService: favoriteService)

        // when
        sut.isFavorite = false

        // then
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        XCTAssertFalse(favoriteService.favorites.contains(where: { $0.id == TestData.mediaItem.id }))
    }
}

private extension MediaDetailViewModelTests {
    enum TestData {
        static let mediaItem = MediaItem(media: PreviewData.movieDetailData, genreList: PreviewData.genreListData)
    }
}
