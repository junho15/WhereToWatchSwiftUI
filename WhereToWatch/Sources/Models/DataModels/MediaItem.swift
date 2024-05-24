import Foundation
import MovieDatabaseAPI

struct MediaItem: Identifiable, Equatable, Hashable, Sortable {
    let id: Int
    let mediaType: MediaType
    let posterPath: String?
    let backdropPath: String?
    let title: String?
    let genre: String?
    let date: Date?
    let overview: String?
    var favoriteRegistrationDate: Date?

    init(
        id: Int, mediaType: MediaType, posterPath: String?, backdropPath: String?,
        title: String?, genre: String?, date: Date?, overview: String?, favoriteRegistrationDate: Date? = nil
    ) {
        self.id = id
        self.mediaType = mediaType
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.title = title
        self.genre = genre
        self.date = date
        self.overview = overview
        self.favoriteRegistrationDate = favoriteRegistrationDate
    }

    init(media: any MediaProtocol, genreList: GenreList?, favoriteRegistrationDate: Date? = nil) {
        self.id = media.id
        self.mediaType = media.mediaType
        self.posterPath = media.posterPath
        self.backdropPath = media.backdropPath
        self.title = media.title
        self.date = media.date
        self.overview = media.overview
        self.favoriteRegistrationDate = favoriteRegistrationDate

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
        imageURL(path: posterPath, size: .w500)
    }

    var backdropURL: URL? {
        imageURL(path: backdropPath, size: .w500)
    }

    var year: String? {
        date?.year
    }
}
