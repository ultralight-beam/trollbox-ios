import Foundation
import CoreData


extension Conversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conversation> {
        return NSFetchRequest<Conversation>(entityName: "Conversation")
    }

    @NSManaged public var name: NSObject?
    @NSManaged public var message: NSSet?

}

// MARK: Generated accessors for message
extension Conversation {

    @objc(addMessageObject:)
    @NSManaged public func addToMessage(_ value: Messages)

    @objc(removeMessageObject:)
    @NSManaged public func removeFromMessage(_ value: Messages)

    @objc(addMessage:)
    @NSManaged public func addToMessage(_ values: NSSet)

    @objc(removeMessage:)
    @NSManaged public func removeFromMessage(_ values: NSSet)

}
