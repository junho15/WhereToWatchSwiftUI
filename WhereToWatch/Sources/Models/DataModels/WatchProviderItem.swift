import Foundation
import MovieDatabaseAPI

struct WatchProviderItem: Identifiable {
    let id: Int
    let logoPath: String?
    let providerName: String?
    let displayPriority: Int?

    init(id: Int, logoPath: String?, providerName: String?, displayPriority: Int?) {
        self.id = id
        self.logoPath = logoPath
        self.providerName = providerName
        self.displayPriority = displayPriority
    }

    init(watchProvider: WatchProvider) {
        self.id = watchProvider.id
        self.logoPath = watchProvider.logoPath
        self.providerName = watchProvider.providerName
        self.displayPriority = watchProvider.displayPriority
    }
}

extension WatchProviderItem: ImageURLRepresentable {
    var logoURL: URL? {
        imageURL(path: logoPath, size: .original)
    }
}
