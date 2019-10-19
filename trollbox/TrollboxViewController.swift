import UIKit
import MessageKit

public struct Sender: SenderType {
    public let senderId: String

    public let displayName: String
}

class TrollboxViewController: MessagesViewController {

    var messages = [MessageType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        if traitCollection.userInterfaceStyle == .light {
            messageInputBar.inputTextView.textColor = .black
        } else {
            messagesCollectionView.backgroundColor = .black
            messageInputBar.backgroundColor = .black
            messageInputBar.inputTextView.backgroundColor = .black
            messageInputBar.backgroundView.backgroundColor = .black
        }

    }
}

let sender = Sender(senderId: "any_unique_id", displayName: "Steven")

extension TrollboxViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(senderId: "any_unique_id", displayName: "Steven")

    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension TrollboxViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {

}
