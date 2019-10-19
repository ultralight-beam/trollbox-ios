import UIKit
import MessageKit
import InputBarAccessoryView
import UB

public struct Sender: SenderType {
    public let senderId: String

    public let displayName: String
}

class TrollboxViewController: MessagesViewController {

    var node = Node()

    var messages = [MessageType]()

    override func viewDidLoad() {
        super.viewDidLoad()

        node.delegate = self
        node.add(transport: CoreBluetoothTransport())

        title = "Trollbox"

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messageInputBar.delegate = self

        if traitCollection.userInterfaceStyle == .light {
            messageInputBar.inputTextView.textColor = .black
        } else {
            messagesCollectionView.backgroundColor = .black
            messageInputBar.backgroundColor = .black
            messageInputBar.inputTextView.backgroundColor = .black
            messageInputBar.backgroundView.backgroundColor = .black
        }

    }

    func insertMessage(_ message: MockMessage) {
        messages.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }

    func isLastSectionVisible() -> Bool {

        guard !messages.isEmpty else {
            return false
        }

        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)

        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
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

extension TrollboxViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let components = inputBar.inputTextView.text!
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {

            guard let test = components.data(using: .utf8) else {
                return
            }

            let m = Message(service: UBID(repeating: 1, count: 1),
                recipient: UBID(repeating: 0, count: 0),
                from: UBID(repeating: 1, count: 1),
                origin: UBID(repeating: 1, count: 1),
                message: test)

            self.node.send(m)

            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                let message = MockMessage(text: components, user: sender, messageId: UUID().uuidString, date: Date())
                self?.insertMessage(message)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
}

extension TrollboxViewController: NodeDelegate {

    func node(_ node: Node, didReceiveMessage message: Message) {
        if message.service != UBID(repeating: 1, count: 1) {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let text = String(data: message.message, encoding: .utf8) else {
                return
            }

            self?.insertMessage(
                MockMessage(text: text, user: Sender(senderId: "new id", displayName: "Foo"), messageId: UUID().uuidString, date: Date())
            )
        }
    }

}

internal struct MockMessage: MessageType {

    var messageId: String
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind

    var user: SenderType

    private init(kind: MessageKind, user: SenderType, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }

    init(text: String, user: SenderType, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }
}
