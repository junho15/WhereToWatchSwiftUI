import Foundation

enum FavoritesSortOption: CaseIterable, CustomStringConvertible {
    case registrationDate
    case reverseRegistrationDate
    case title
    case reverseTitle
    case year
    case reverseYear

    var comparator: (_ lhs: Sortable, _ rhs: Sortable) -> Bool {
        return { lhs, rhs in
            switch self {
            case .registrationDate:
                return lhs.favoriteRegistrationDate ?? Date() < rhs.favoriteRegistrationDate ?? Date()
            case .reverseRegistrationDate:
                return lhs.favoriteRegistrationDate ?? Date() > rhs.favoriteRegistrationDate ?? Date()
            case .title:
                return lhs.title ?? "" < rhs.title ?? ""
            case .reverseTitle:
                return lhs.title ?? "" > rhs.title ?? ""
            case .year:
                return lhs.date ?? Date() < rhs.date ?? Date()
            case .reverseYear:
                return lhs.date ?? Date() > rhs.date ?? Date()
            }
        }
    }

    var description: String {
        switch self {
        case .registrationDate:
            return NSLocalizedString(
                "REGISTRATION_DATE_ORDER_DESCRIPTION", comment: "Registration Date Order Description"
            )
        case .reverseRegistrationDate:
            return NSLocalizedString(
                "REVERSE_REGISTRATION_DATE_ORDER_DESCRIPTION",
                comment: "Reverse Registration Date Order Description"
            )
        case .title:
            return NSLocalizedString(
                "TITLE_ORDER_DESCRIPTION", comment: "Title Order Description"
            )
        case .reverseTitle:
            return NSLocalizedString(
                "REVERSE_TITLE_ORDER_DESCRIPTION", comment: "Reverse Title Order Description"
            )
        case .year:
            return NSLocalizedString(
                "REGISTRATION_DATE_ORDER_DESCRIPTION", comment: "Registration Date Order Description"
            )
        case .reverseYear:
            return NSLocalizedString(
                "REGISTRATION_DATE_ORDER_DESCRIPTION", comment: "Registration Date Order Description"
            )
        }
    }
}

protocol Sortable {
    var id: Int { get }
    var title: String? { get }
    var date: Date? { get }
    var favoriteRegistrationDate: Date? { get }
}
