import UIKit
import MessageKit
import InputBarAccessoryView
import UB
import CryptoKit

class TrollboxViewController: MessagesViewController {

    var node = Node(key: Curve25519.Signing.PrivateKey())

    var messages = [MessageType]() {
        didSet {
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        node.delegate = self
        node.add(transport: CoreBluetoothTransport())

        title = "Trollbox"

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messageInputBar.delegate = self
        messageInputBar.inputTextView.placeholder = "Message"

        if traitCollection.userInterfaceStyle == .light {
            messageInputBar.inputTextView.textColor = .black
        } else {
            messagesCollectionView.backgroundColor = .black
            messageInputBar.backgroundColor = .black
            messageInputBar.inputTextView.backgroundColor = .black
            messageInputBar.backgroundView.backgroundColor = .black
        }

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
        return sender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension TrollboxViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: "0x\(message.sender.displayName.prefix(5))",
            attributes: [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)
            ]
        )
    }

    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        if message.sender as! Sender != sender {
            return 20.0
        }

        return 0.0
    }
}

extension TrollboxViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let text = inputBar.inputTextView.text!
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            guard let encodedText = text.data(using: .utf8) else {
                return
            }

            self.node.send(
                UB.Message(
                    service: UBID(repeating: 1, count: 1),
                    recipient: UBID(repeating: 0, count: 0),
                    from: UBID(repeating: 1, count: 1),
                    origin: UBID(repeating: 1, count: 1),
                    message: encodedText
                )
            )

            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Message"
                let message = Message(
                    text: text,
                    user: sender,
                    messageId: UUID().uuidString, // @todo some calculatable
                    date: Date()
                )
                self?.messages.append(message)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
}

extension TrollboxViewController: NodeDelegate {

    func node(_ node: Node, didReceiveMessage message: UB.Message) {
        if message.service != UBID(repeating: 1, count: 1) {
            return
        }

        let hex = message.from.hex

        DispatchQueue.main.async { [weak self] in
            guard let text = String(data: message.message, encoding: .utf8) else {
                return
            }

            self?.messages.append(
                Message(
                    text: text,
                    user: Sender(senderId: hex, displayName: hex),
                    messageId: UUID().uuidString, date: Date()
                )
            )
        }
    }
}
