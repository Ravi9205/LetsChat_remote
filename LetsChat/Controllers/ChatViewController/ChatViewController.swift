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
        return  Sender(PhotoURL:"", senderId: email, displayName:"Ravi dwiveid")
    }
    
    public var isNewConversation = false
    public let  otherUserEmail:String
    
    init(with email:String) {
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
    }
    
    
}

//MARK:- InputBar AccessoryView Delegates

extension ChatViewController:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of:" ", with:"").isEmpty , let selfSender = selfSender ,let messageId = createMessageID() else {
            return
        }
        //MARK:- DO stuff for sending end to end messages
        
        print("Sended Text ===\(text)")
        if isNewConversation {
            //Create conversation in Database manager
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail,name:self.title ?? "User", firstMessage: message) { success in
                
                if success {
                    print("Message sent")
                }
                else {
                    print("Error occured sending messages")
                }
            }
            
        }else {
            // Append to Existing Conversation data
            
        }
    }
    
    private func  createMessageID()->String?{
        
        let dateString = ChatViewController.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey:"email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
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
