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
        sut = MediaDetailViewModel(mediaItem: TestData.mediaItem, favoriteService: favoriteService)

        // then
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        XCTAssertTrue(sut.isFavorite ?? false)
    }

    @MainActor
    func testAddingFavorite() async {
        // given
        favoriteService.favorites = []
        sut = MediaDetailViewModel(mediaItem: TestData.mediaItem, favoriteService: favoriteService)
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)

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
        sut = MediaDetailViewModel(mediaItem: TestData.mediaItem, favoriteService: favoriteService)
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)

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
