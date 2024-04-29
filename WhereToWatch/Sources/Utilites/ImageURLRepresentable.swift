import Foundation
import MovieDatabaseAPI

protocol ImageURLRepresentable {
    func imageURL(path: String?, size: MovieDatabaseURL.ImageSize) -> URL?
}

extension ImageURLRepresentable {
    func imageURL(path: String?, size: MovieDatabaseURL.ImageSize) -> URL? {
        guard let path else { return nil }

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "image.tmdb.org"
        urlComponents.path = "/t/p\(size.stringValue)\(path)"
        return urlComponents.url
    }
}
