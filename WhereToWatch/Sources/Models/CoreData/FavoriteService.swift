import CoreData

protocol FavoriteServiceProtocol {
    func contains(_ id: FavoriteMediaItem.ID) throws -> Bool
    func fetch(sortOption: FavoritesSortOption, offset: Int?, limit: Int?) throws -> [FavoriteMediaItem]
    func add(_ favoriteMediaItem: FavoriteMediaItem) throws
    func remove(_ id: FavoriteMediaItem.ID) throws
}

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

extension FavoriteService: FavoriteServiceProtocol {
    func contains(_ id: FavoriteMediaItem.ID) throws -> Bool {
        let result = try fetch(id: id)
        return result.isEmpty == false
    }

    func fetch(
        sortOption: FavoritesSortOption = .registrationDate, offset: Int? = nil, limit: Int? = nil
    ) throws -> [FavoriteMediaItem] {
        let request = fetchRequest
        request.sortDescriptors = [sortOption.sortDescriptor]

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
    private enum Constants {
        static let persistentContainerName = "Model"
        static let idPredicateFormat = "id == %lld"
    }
}
