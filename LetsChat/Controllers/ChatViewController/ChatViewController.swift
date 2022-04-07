//
//  ChatViewController.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 22/03/22.
//

import UIKit
import MessageKit

class ChatViewController:  MessagesViewController , MessagesDataSource , MessagesDisplayDelegate , MessagesLayoutDelegate {
    
    let currentUser = Sender(senderId:"self", displayName:"iOS World")
    
    let otherUser = Sender(senderId:"other", displayName:" Jhone Smith")
    
    var  messages = [MessageType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messages.append(Message(sender: currentUser, messageId:"1", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello World, This world is just awesome")))
        
        messages.append(Message(sender: otherUser, messageId:"2", sentDate: Date().addingTimeInterval(-70400), kind: .text("Hello World, This world is just awesome, Hey baby how you doing ")))
        
        messages.append(Message(sender: currentUser, messageId:"3", sentDate: Date().addingTimeInterval(-66400), kind: .text("Hello World, This world is just awesome , Look into this fucking world")))
        
        messages.append(Message(sender: otherUser, messageId:"4", sentDate: Date().addingTimeInterval(-56400), kind: .text("Hello World, This world is just awesome hasfjhvshjdf ashfvhjsdavf  asjdfbkjasdf")))
        
        messages.append(Message(sender: currentUser, messageId:"5", sentDate: Date().addingTimeInterval(-46400), kind: .text("Hello World, This world is just awesome , Look into this fucking world, I got crazy about this ")))
        
        messages.append(Message(sender: otherUser, messageId:"6", sentDate: Date().addingTimeInterval(-36400), kind: .text("Hello World, This world is just awesome hasfjhvshjdf ashfvhjsdavf  asjdfbkjasdf, YOu looks amazing diving into this wonderful world")))
        
        
        // Do any additional setup after loading the view.
    }
    
    // Message Kit delegates and data Sources Method
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    
}
