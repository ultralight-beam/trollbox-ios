import UIKit
import MessageKit

struct Message: MessageType {

    var kind: MessageKind
    var messageId: String
    var sender: SenderType
    var sentDate: Date

    init(text: String, user: SenderType, messageId: String, date: Date) {
        kind = .text(text)
        self.sender = user
        self.messageId = messageId
        self.sentDate = date
    }

}
