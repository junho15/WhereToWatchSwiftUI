import Foundation

enum FavoritesSortOption: CaseIterable, CustomStringConvertible {
    case registrationDate
    case reverseRegistrationDate

    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .registrationDate:
            return NSSortDescriptor(key: "registrationDate", ascending: true)
        case .reverseRegistrationDate:
            return NSSortDescriptor(key: "registrationDate", ascending: false)
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
        }
    }
}
