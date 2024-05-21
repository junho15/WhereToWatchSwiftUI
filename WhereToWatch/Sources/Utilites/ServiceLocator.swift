import MovieDatabaseAPI

final class ServiceLocator {

    // MARK: Properties

    static let shared = ServiceLocator()

    private lazy var movieDatabaseAPIClient = MovieDatabaseAPIClient(apiKey: Secrets.apiKey)
    private lazy var genresListFetcher = GenresListFetcher(movieDatabaseAPIClient: movieDatabaseAPIClient)
    private lazy var favoriteService = FavoriteService()

    // MARK: Lifecycle

    private init() {}
}

// MARK: - Methods

extension ServiceLocator {
    func getService<T>(type: T.Type) -> T? {
        switch T.self {
        case is MovieDatabaseAPIClient.Type:
            return movieDatabaseAPIClient as? T
        case is GenresListFetcher.Type:
            return genresListFetcher as? T
        case is FavoriteService.Type:
            return favoriteService as? T
        default:
            return nil
        }
    }
}

@propertyWrapper
struct Injected<Service> {
    var wrappedValue: Service

    init() {
        guard let service = ServiceLocator.shared.getService(type: Service.self) else {
            fatalError("Service \(Service.self) not found.")
        }
        self.wrappedValue = service
    }
}
