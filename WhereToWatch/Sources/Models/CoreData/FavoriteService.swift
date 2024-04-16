import CoreData

final class FavoriteService {
    typealias FetchRequest = NSFetchRequest<MediaItemEntity>

    static let shared = FavoriteService()

    private lazy var persistenceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.persistentContainerName)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError(error.localizedDescription)
            }
        }

        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        return container
    }()

    private var context: NSManagedObjectContext {
        return persistenceContainer.viewContext
    }

    private var fetchRequest: FetchRequest {
        return MediaItemEntity.fetchRequest()
    }

    private init() { }
}

extension FavoriteService {
    func contains(_ id: FavoriteMediaItem.ID) throws -> Bool {
        let result = try fetch(id: id)
        return result.isEmpty == false
    }

    func fetch(
        sortOption: SortOption = .registrationDate, query: String? = nil, offset: Int? = nil, limit: Int? = nil
    ) throws -> [FavoriteMediaItem] {
        let request = fetchRequest
        request.sortDescriptors = [sortOption.sortDescriptor]

        if let query,
           query.isEmpty == false {
            request.predicate = NSPredicate(format: Constants.titlePredicateFormat, query)
        }

        if let offset,
           let limit {
            request.fetchOffset = offset
            request.fetchLimit = limit
        }

        let result = try context.fetch(request)
        return result.compactMap { mediaItemEntity in
            FavoriteMediaItem(mediaItemEntity: mediaItemEntity)
        }
    }

    func add(_ favoriteMediaItem: FavoriteMediaItem) throws {
        let mediaItemEntity = MediaItemEntity(context: context)
        mediaItemEntity.id = Int64(favoriteMediaItem.id)
        mediaItemEntity.mediaTypeText = favoriteMediaItem.mediaType.rawValue
        mediaItemEntity.registrationDate = favoriteMediaItem.registrationDate

        try save()
    }

    func remove(_ id: FavoriteMediaItem.ID) throws {
        let result = try fetch(id: id)
        guard let deleted = result.first else { return }

        try delete(item: deleted)
    }

    private func fetch(id: Int) throws -> [MediaItemEntity] {
        let request = fetchRequest
        request.predicate = NSPredicate(format: Constants.idPredicateFormat, id)
        return try context.fetch(request)
    }

    private func save() throws {
        guard context.hasChanges else { return }

        try context.save()
    }

    private func delete(item: MediaItemEntity) throws {
        context.delete(item)

        try save()
    }
}

extension FavoriteService {
    enum SortOption: CaseIterable, CustomStringConvertible {
        case registrationDate
        case reverseRegistrationDate
        case title
        case reverseTitle

        fileprivate var sortDescriptor: NSSortDescriptor {
            switch self {
            case .registrationDate:
                return NSSortDescriptor(key: "registrationDate", ascending: true)
            case .reverseRegistrationDate:
                return NSSortDescriptor(key: "registrationDate", ascending: false)
            case .title:
                return NSSortDescriptor(key: "title", ascending: true)
            case .reverseTitle:
                return NSSortDescriptor(key: "title", ascending: false)
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
            }
        }
    }

    private enum Constants {
        static let persistentContainerName = "Model"
        static let titlePredicateFormat = "title CONTAINS %@"
        static let idPredicateFormat = "id == %lld"
    }
}
