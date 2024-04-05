import MovieDatabaseAPI

struct MediaItem: Identifiable {
    let id: Int
    let mediaType: MediaType
    let posterPath: String?
    let backdropPath: String?
    let title: String?
    let genre: String?
    let year: String?
    let overview: String?

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
