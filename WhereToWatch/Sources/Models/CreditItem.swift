import Foundation
import MovieDatabaseAPI

struct CreditItem: Identifiable {
    let id: Int
    let name: String?
    let character: String?
    let profilePath: String?

    init(id: Int, name: String?, character: String?, profilePath: String?) {
        self.id = id
        self.name = name
        self.character = character
        self.profilePath = profilePath
    }

    init(credit: Credit) {
        self.id = credit.id
        self.name = credit.name
        self.character = credit.character
        self.profilePath = credit.profilePath
    }
}
