import Foundation

protocol LocaleRepresentable {
    var languageCode: String? { get }
    var countryCode: String? { get }
    var languageCountryCode: String? { get }
}

extension LocaleRepresentable {
    var languageCode: String? {
        return Locale.current.language.languageCode?.identifier
    }

    var countryCode: String? {
        return Locale.current.language.region?.identifier
    }

    var languageCountryCode: String? {
        guard let languageCode, let countryCode else { return nil }
        return "\(languageCode)-\(countryCode)"
    }
}
