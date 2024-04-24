import CoreData

protocol FavoriteServiceProtocol {
    func contains(_ id: FavoriteMediaItem.ID) async throws -> Bool
    func fetch(sortOption: FavoritesSortOption, offset: Int?, limit: Int?) async throws -> [FavoriteMediaItem]
    func add(_ favoriteMediaItem: FavoriteMediaItem) async throws
    func remove(_ id: FavoriteMediaItem.ID) async throws
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
    func contains(_ id: FavoriteMediaItem.ID) async throws -> Bool {
        let result = try await fetch(id: id)
        return result.isEmpty == false
    }

    func fetch(
        sortOption: FavoritesSortOption = .registrationDate, offset: Int? = nil, limit: Int? = nil
    ) async throws -> [FavoriteMediaItem] {
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

    func add(_ favoriteMediaItem: FavoriteMediaItem) async throws {
        let mediaItemEntity = MediaItemEntity(context: context)
        mediaItemEntity.id = Int64(favoriteMediaItem.id)
        mediaItemEntity.mediaTypeText = favoriteMediaItem.mediaType.rawValue
        mediaItemEntity.registrationDate = favoriteMediaItem.registrationDate

        try await save()
    }

    func remove(_ id: FavoriteMediaItem.ID) async throws {
        let result = try await fetch(id: id)
        guard let deleted = result.first else { return }

        try await delete(item: deleted)
    }
}

private extension FavoriteService {
    func fetch(id: Int) async throws -> [MediaItemEntity] {
        let request = fetchRequest
        request.predicate = NSPredicate(format: Constants.idPredicateFormat, id)
        return try context.fetch(request)
    }

    func save() async throws {
        guard context.hasChanges else { return }

        try context.save()
    }

    func delete(item: MediaItemEntity) async throws {
        context.delete(item)

        try await save()
    }
}

extension FavoriteService {
    private enum Constants {
        static let persistentContainerName = "Model"
        static let idPredicateFormat = "id == %lld"
    }
}
