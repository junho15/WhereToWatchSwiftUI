import Foundation
import MovieDatabaseAPI

struct MediaItem: Identifiable, Equatable {
    let id: Int
    let mediaType: MediaType
    let posterPath: String?
    let backdropPath: String?
    let title: String?
    let genre: String?
    let year: String?
    let overview: String?

    init(
        id: Int, mediaType: MediaType, posterPath: String?, backdropPath: String?,
        title: String?, genre: String?, year: String?, overview: String?
    ) {
        self.id = id
        self.mediaType = mediaType
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.title = title
        self.genre = genre
        self.year = year
        self.overview = overview
    }

    init(media: any MediaProtocol, genreList: GenreList?) {
        self.id = media.id
        self.mediaType = media.mediaType
        self.posterPath = media.posterPath
        self.backdropPath = media.backdropPath
        self.title = media.title
        self.year = media.date?.year
        self.overview = media.overview

        guard let genreIds = media.genreIds else {
            self.genre = nil
            return
        }

        self.genre = genreList?.genres.compactMap { genre in
            return genreIds.contains(genre.id) ? genre.name : nil
        }.joined(separator: ", ")
    }
}

extension MediaItem: ImageURLRepresentable {
    var posterURL: URL? {
        return imageURL(path: posterPath, size: .w500)
    }

    var backdropURL: URL? {
        imageURL(path: backdropPath, size: .w500)
    }
}
