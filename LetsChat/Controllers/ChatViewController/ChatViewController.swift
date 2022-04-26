//
//  ChatViewController.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 22/03/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController:  MessagesViewController  {
    
    
    public static let dateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .long
        dateFormatter.locale = .current
        return dateFormatter
        
    }()
    
    var  messages = [MessageType]()
    
    private var selfSender: Sender? {
        
        guard let email = UserDefaults.standard.value(forKey:"email") as? String  else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return  Sender(PhotoURL:"", senderId: safeEmail, displayName:"Me")
    }
    
    public var isNewConversation = false
    public var isShouldScrollToBottom = false
    public let  otherUserEmail:String
    private var conversationId:String?
    
    init(with email:String, id:String?) {
        self.conversationId = id
        self.otherUserEmail = email
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
        messageInputBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
        
    }
    

    private func listenForMessages(id: String, shouldScrollToBottom: Bool){
        DatabaseManager.shared.getAllMessagesForConversation(with: id){[weak self] result in
            switch result {
            case .success( let messages):
                print("Success in gettting messages:\(messages)")
                guard !messages.isEmpty else {
                    print("Messages are empty!")
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                    
                }
            case .failure(let error):
                print("Failed to fetech all the messages\(error)")
            }
        }
    }
}

//MARK:- InputBar AccessoryView Delegates

extension ChatViewController:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of:" ", with:"").isEmpty , let selfSender = self.selfSender ,let messageId = createMessageID() else {
            return
        }
        print("Sended Text ===\(text)")

        //MARK:- DO stuff for sending end to end messages
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        if isNewConversation {
            //Create conversation in Database manager
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail,name:self.title ?? "User", firstMessage: message, completion:{[weak self] success in
                
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                }
                else {
                    print("Error occured sending messages")
                }
            })
            
        }else {
            // Append to Existing Conversation data
            guard let conversationId = self.conversationId ,let name = self.title else {
                return
            }
            
            DatabaseManager.shared.sendMessage(to:conversationId,name:name, message: message,completion:{ [weak self] success in
                
                guard let strongSelf = self else {
                    return
                }
                
                if success {
                    print("Message sent")
                    strongSelf.messageInputBar.inputTextView.text = nil
                        
                    }
                   else {
                    print("Failed to send messsages")
                }
                
            })
        }
    }
    
    private func  createMessageID()->String?{
        guard let currentUserEmail = UserDefaults.standard.value(forKey:"email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeEmail)_\(dateString)"
        return newIdentifier
    }
}

//MARK:- MessageKit Layout Delegate && Data Source for chat Layout and its basic setup

extension ChatViewController:  MessagesDataSource , MessagesDisplayDelegate , MessagesLayoutDelegate{
    // Message Kit delegates and data Sources Method
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        //fatalError("self sender is nil , email should be chached")
        return Sender(PhotoURL:"", senderId:"12", displayName:"")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
