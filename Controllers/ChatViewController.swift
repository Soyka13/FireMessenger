//
//  ChatViewController.swift
//  Messenger
//
//  Created by Olena Stepaniuk on 10.11.2020.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    public let otherUserEmail: String
    private var conversationId: String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: email)
        
        return Sender(senderId: safeEmail, displayName: "Me")
    }
    
    
    init(with email: String, id: String?) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        
        if let convId = conversationId {
            listenForMessages(id: convId, shouldScrollToBottom: true)
        }
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self](result) in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                
                print("Successfully get messages")
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
                
            case .failure(let error):
                print("failed to get messages: \(error.localizedDescription)")
            }
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            print("Here")
            return
        }
        
        print("Sending: \(text)")
        
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        // Send Message
        if isNewConversation {
            // create conversation in database
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self](success) in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("failed to send")
                }
            }
            
        } else {
            // append to existing conversation data
            
            guard let convId = conversationId, let name = self.title else {
                return
            }
            
            DatabaseManager.shared.sendMessage(to: convId, otherUserEmail: otherUserEmail, name: name, newMessage: message) { [weak self](success) in
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("message sent")
                } else {
                    print("failed to send")
                } 
            }
        }
    }
    
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, random int
        
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("Create message id \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

extension ChatViewController: MessageCellDelegate {}
