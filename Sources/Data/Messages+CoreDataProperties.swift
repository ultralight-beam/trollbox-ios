import Foundation
import CoreData


extension Messages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Messages> {
        return NSFetchRequest<Messages>(entityName: "Message")
    }

    @NSManaged public var message: NSObject?
    @NSManaged public var conversation: Conversation?

}
