@testable import WhereToWatch
import Foundation

@MainActor
final class MockFavoriteService: FavoriteServiceProtocol {
    var favorites: [FavoriteMediaItem] = []
    var shouldReturnError = false
    var sortOption = FavoritesSortOption.registrationDate

    func contains(_ id: FavoriteMediaItem.ID) async throws -> Bool {
        guard shouldReturnError == false else {
            throw NSError(domain: "MockFavoriteServiceError", code: 0, userInfo: nil)
        }
        return favorites.contains(where: { $0.id == id })
    }

    func fetch(sortOption: FavoritesSortOption, offset: Int?, limit: Int?) async throws -> [FavoriteMediaItem] {
        guard shouldReturnError == false else {
            throw NSError(domain: "MockFavoriteServiceError", code: 0, userInfo: nil)
        }
        self.sortOption = sortOption
        return favorites
    }

    func add(_ favoriteMediaItem: FavoriteMediaItem) async throws {
        guard shouldReturnError == false else {
            throw NSError(domain: "MockFavoriteServiceError", code: 0, userInfo: nil)
        }
        favorites.append(favoriteMediaItem)
    }

    func remove(_ id: FavoriteMediaItem.ID) async throws {
        guard shouldReturnError == false else {
            throw NSError(domain: "MockFavoriteServiceError", code: 0, userInfo: nil)
        }
        favorites.removeAll(where: { $0.id == id })
    }
}