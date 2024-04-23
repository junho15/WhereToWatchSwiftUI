import MovieDatabaseAPI
import UIKit

final class MockMovieDatabaseAPIClient: MovieDatabaseAPIClientProtocol {
    var searchMoviesResult: Page<Movie>?
    var searchTVShowsResult: Page<TVShow>?
    var movieWatchProvidersResult: WatchProviderResult?
    var tvShowWatchProvidersResult: WatchProviderResult?
    var movieGenresListResult: GenreList?
    var tvShowGenresListResult: GenreList?
    var fetchImageResult: UIImage?
    var trendingMoviesResult: Page<Movie>?
    var trendingTVShowsResult: Page<TVShow>?
    var movieCreditsResult: [Credit]?
    var tvShowCreditsResult: [Credit]?
    var similarMoviesResult: Page<Movie>?
    var similarTVShowsResult: Page<TVShow>?
    var movieDetailResult: Movie?
    var tvShowDetailResult: TVShow?

    var searchMoviesError: Error?
    var searchTVShowsError: Error?
    var movieWatchProvidersError: Error?
    var tvShowWatchProvidersError: Error?
    var movieGenresListError: Error?
    var tvShowGenresListError: Error?
    var fetchImageError: Error?
    var trendingMoviesError: Error?
    var trendingTVShowsError: Error?
    var movieCreditsError: Error?
    var tvShowCreditsError: Error?
    var similarMoviesError: Error?
    var similarTVShowsError: Error?
    var movieDetailError: Error?
    var tvShowDetailError: Error?

    func searchMovies(
        query: String, language: String? = nil, page: Int? = nil, includeAdult: Bool? = nil,
        region: String? = nil, year: Int? = nil, primaryReleaseYear: Int? = nil
    ) async throws -> Page<Movie> {
        if let searchMoviesError {
            throw searchMoviesError
        }
        return searchMoviesResult!
    }

    func searchTVShows(
        query: String, language: String? = nil, page: Int? = nil,
        includeAdult: Bool? = nil, firstAirDateYear: Int? = nil
    ) async throws -> Page<TVShow> {
        if let searchTVShowsError {
            throw searchTVShowsError
        }
        return searchTVShowsResult!
    }

    func fetchMovieWatchProviders(movieID: Movie.ID) async throws -> WatchProviderResult {
        if let movieWatchProvidersError {
            throw movieWatchProvidersError
        }
        return movieWatchProvidersResult!
    }

    func fetchTVShowWatchProviders(tvShowID: TVShow.ID) async throws -> WatchProviderResult {
        if let tvShowWatchProvidersError {
            throw tvShowWatchProvidersError
        }
        return tvShowWatchProvidersResult!
    }

    func fetchMovieGenresList(language: String) async throws -> GenreList {
        if let movieGenresListError {
            throw movieGenresListError
        }
        return movieGenresListResult!
    }

    func fetchTVShowGenresList(language: String) async throws -> GenreList {
        if let tvShowGenresListError {
            throw tvShowGenresListError
        }
        return tvShowGenresListResult!
    }

    func fetchImage(imageSize: MovieDatabaseURL.ImageSize, imagePath: String) async throws -> UIImage? {
        if let fetchImageError {
            throw fetchImageError
        }
        return fetchImageResult
    }

    func fetchTrendingMovies(timeWindow: MovieDatabaseURL.TimeWindow, language: String) async throws -> Page<Movie> {
        if let trendingMoviesError {
            throw trendingMoviesError
        }
        return trendingMoviesResult!
    }

    func fetchTrendingTVShows(timeWindow: MovieDatabaseURL.TimeWindow, language: String) async throws -> Page<TVShow> {
        if let trendingTVShowsError {
            throw trendingTVShowsError
        }
        return trendingTVShowsResult!
    }

    func fetchMovieCredits(movieID: Movie.ID, language: String) async throws -> [Credit] {
        if let movieCreditsError {
            throw movieCreditsError
        }
        return movieCreditsResult!
    }

    func fetchTVShowCredits(tvShowID: TVShow.ID, language: String) async throws -> [Credit] {
        if let tvShowCreditsError {
            throw tvShowCreditsError
        }
        return tvShowCreditsResult!
    }

    func fetchSimilarMovies(movieID: Movie.ID, language: String, page: Int? = nil) async throws -> Page<Movie> {
        if let similarMoviesError {
            throw similarMoviesError
        }
        return similarMoviesResult!
    }

    func fetchSimilarTVShows(tvShowID: TVShow.ID, language: String, page: Int? = nil) async throws -> Page<TVShow> {
        if let similarTVShowsError {
            throw similarTVShowsError
        }
        return similarTVShowsResult!
    }

    func fetchMovieDetail(movieID: Movie.ID, language: String) async throws -> Movie {
        if let movieDetailError {
            throw movieDetailError
        }
        return movieDetailResult!
    }

    func fetchTVShowDetail(tvShowID: TVShow.ID, language: String) async throws -> TVShow {
        if let tvShowDetailError {
            throw tvShowDetailError
        }
        return tvShowDetailResult!
    }
}
