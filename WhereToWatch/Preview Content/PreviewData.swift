import UIKit
import MovieDatabaseAPI

enum PreviewData {
    static let creditsData: Credits = load("CreditsData")
    static let genreListData: GenreList = load("GenreListData")
    static let movieDetailData: Movie = load("MovieDetailData")
    static let moviePageData: Page<Movie> = load("MoviePageData")
    static let similarMovieData: Page<Movie> = load("SimilarMovieData")
    static let similarTVShowData: Page<TVShow> = load("SimilarTVShowData")
    static let tvShowDetailData: TVShow = load("TvShowDetailData")
    static let tvShowPageData: Page<TVShow> = load("TvShowPageData")
    static let watchProviderResultData: WatchProviderResult = load("WatchProviderResultData")

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    private static func load<T: Decodable>(_ name: String) -> T {
        guard let jsonDataAsset = NSDataAsset(name: name) else {
            fatalError("\(name)를 찾을 수 없습니다.")
        }

        do {
            return try decoder.decode(T.self, from: jsonDataAsset.data)
        } catch {
            fatalError("디코딩에 실패했습니다. \(error.localizedDescription)")
        }
    }
}
