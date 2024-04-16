import Foundation
import CoreData

extension MediaItemEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaItemEntity> {
        return NSFetchRequest<MediaItemEntity>(entityName: "MediaItemEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var mediaTypeText: String
    @NSManaged public var registrationDate: Date?
}

extension MediaItemEntity: Identifiable { }
