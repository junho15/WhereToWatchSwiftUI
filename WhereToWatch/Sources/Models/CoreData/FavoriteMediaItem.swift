import Foundation
import MovieDatabaseAPI

struct FavoriteMediaItem: Identifiable, Equatable {
    let id: MediaItem.ID
    let mediaType: MediaType
    let registrationDate: Date?

    init?(mediaItemEntity: MediaItemEntity) {
        guard let mediaType = MediaType(rawValue: mediaItemEntity.mediaTypeText) else {
            return nil
        }

        self.id = Int(mediaItemEntity.id)
        self.mediaType = mediaType
        self.registrationDate = mediaItemEntity.registrationDate
    }

    init(mediaItem: MediaItem, registrationDate: Date = Date()) {
        self.id = mediaItem.id
        self.mediaType = mediaItem.mediaType
        self.registrationDate = registrationDate
    }
}
