//
//  DatabaseManager.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 29/03/22.
//

import Foundation
import FirebaseDatabase


final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress:String) ->String {
        var  emailStr = emailAddress.replacingOccurrences(of:".", with: "-")
        emailStr = emailStr.replacingOccurrences(of: "@", with: "-")
        return emailStr
    }
    
}


//MARK:- Account Management

extension DatabaseManager {
    
    public func userExits(with email:String,completion:@escaping ((Bool)->Void)){
        var  emailStr = email.replacingOccurrences(of:".", with: "-")
        emailStr = emailStr.replacingOccurrences(of: "@", with: "-")
        database.child(emailStr).observeSingleEvent(of: .value) { dbsnapShot in
            
            guard  dbsnapShot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
            
        }
    }
    
    //MARK:- FUunction to fetch all Users
    public func fetchAllUsers(completion: @escaping(Result<[[String: String]],Error>)->Void){
        
        database.child("users").observeSingleEvent(of: .value) { dataSnapShot in
            
            guard let value = dataSnapShot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.failedToFetchUsers))
                return
            }
            completion(.success(value))
        }
        
    }
    
    //MARK:- Database error
    public enum DatabaseErrors:Error {
        case failedToFetchUsers
        case faildToFetch
    }
    
    
    //MARK:- Insert into dataBase
    public func insertUser(with user:ChatAppUser,completion: @escaping (Bool)->Void){
        
        database.child(user.validEmail).setValue(["first_name":user.firstName,"last_name":user.lastName
                                                 ]) { error, _ in
            guard error == nil else {
                print("Failed to insert into data base")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapShot in
                
                if var usersCollection = snapShot.value as? [[String:String]] {
                    // Appened to user dictionary
                    let newElement = [
                        "name":user.firstName + " " + user.lastName ,
                        "email":user.validEmail
                        
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                        
                    }
                }
                else {
                    // Create array
                    let newCollection :[[String:String]] = [
                        [
                            "name":user.firstName + " " + user.lastName ,
                            "email":user.validEmail
                            
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                        
                    }
                }
            }
            
        }
    }
}


//MARK:- Sending messages / Conversession

extension DatabaseManager{
    
    // Create New Converstion with target users and first message sent
    public func createNewConversation(with otherUserEmail:String,name:String, firstMessage:Message,completion:@escaping(Bool)->Void){
        guard let currentEmail = UserDefaults.standard.value(forKey:"email") as? String ,let currentName = UserDefaults.standard.value(forKey:"name") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let refrence = database.child("\(safeEmail)")
        refrence.observeSingleEvent(of: .value) {[weak self] snapShot in
            guard var userNode = snapShot.value as? [String:Any] else {
                completion(false)
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString =  ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch firstMessage.kind {
                
            case .text( let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData:[String:Any] = [
                "id":conversationID,
                "other_user_email":otherUserEmail,
                "name":name,
                "latest_message": [
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ],
                
            ]
            
            let receipent_newConversationData:[String:Any] = [
                "id":conversationID,
                "other_user_email":safeEmail,
                "name":currentName,
                "latest_message": [
                    "date":dateString,
                    "message":message,
                    "is_read":false
                ],
                
            ]
            
            // update recipient conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapShot in
                
                if var conversations = snapShot.value as? [[String:Any]] {
                    //Append
                    conversations.append(receipent_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue([conversations])
                }
                else {
                    //Create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([receipent_newConversationData])
                }
                
            }
            
            
            // Update Current user Entry 
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user
                // you should append

                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                refrence.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationID,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
            else
            {
                userNode["conversations"] = [
                    newConversationData
                ]
                refrence.setValue(userNode,withCompletionBlock: {[weak self] error, _ in
                    
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(name:name,conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                })
            }
            
        }
    }
    
    
    private func finishCreatingConversation(name:String,conversationID:String,firstMessage:Message, completion:@escaping(Bool)->Void){
        
        // Date String Formatting
        let messageDate = firstMessage.sentDate
        let dateString =  ChatViewController.dateFormatter.string(from: messageDate)
        
        // Currently Text is Processed // Later procced towards more..
        
        var messages = ""
        switch firstMessage.kind {
            
        case .text( let messageText):
            messages = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey:"email") as? String else {
            completion(false)
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let message:[String:Any] = [
            "id":firstMessage.messageId,
            "type":firstMessage.kind.messageKindString,
            "content":messages,
            "date":dateString,
            "sender_email":safeEmail,
            "is_read":false,
            "name":name
        ]
        
        let value:[String:Any] = [
            "messages" : [
                message
            ]
        ]
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
            
        })
    }
    
    
    //MARK:- Fetching and returns all conversations
    public func getAllConversation(for email:String,completion:@escaping (Result<[Conversation],Error>)->Void){
        
        self.database.child("\(email)/conversations").observeSingleEvent(of: .value) { snapShot in
            
            guard let value = snapShot.value as? [[String:Any]] else {
                completion(.failure(DatabaseErrors.faildToFetch))
                return
            }
            
            let conversation:[Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String, let name = dictionary["name"] as? String, let otherUserEmail = dictionary["other_user_email"] as? String, let latestMessage = dictionary["latest_message"] as? [String:Any] ,let date = latestMessage["date"] as? String, let message = latestMessage["message"] as? String,let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
                
            }
            completion(.success(conversation))
            
        }
        
    }
    
    //MARK:- Get All Message Initiated with conversations
    public func getAllMessagesForConversation(with id:String, completion:@escaping(Result<[Message],Error>)->Void) {
        
        database.child("\(id)/messages").observeSingleEvent(of: .value) {[] snapShot in
            
            guard let value = snapShot.value as? [[String:Any]] else {
                completion(.failure(DatabaseErrors.faildToFetch))
                return
            }
            
            let messages:[Message] = value.compactMap { dictionary in
                
                guard let name = dictionary["name"] as? String, let isRead = dictionary["is_read"] as? Bool, let messageId = dictionary["id"] as? String,let content = dictionary["content"] as? String, let dateString = dictionary["date"] as? String, let type = dictionary["type"] as? String,let senderEmail = dictionary["sender_email"] as? String, let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    return  nil
                }
                
                let sender = Sender(PhotoURL:"", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
            }
            completion(.success(messages))
            
        }
        
    }
    //Send message to the target users
    public func sendMessage(to conversation:String,name:String,message:Message, completion:@escaping(Bool)->Void){
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value) {[weak self] snapShot in
            
            guard let StrongSelf = self else {
                return
            }
            
            guard var currentMessages = snapShot.value as? [[String:Any]] else {
                completion(false)
                return
            }
            
            // Append the new messages
            // Date String Formatting
            let messageDate = message.sentDate
            let dateString =  ChatViewController.dateFormatter.string(from: messageDate)
            
            // Currently Text is Processed // Later procced towards more..
            
            var messages = ""
            switch message.kind {
                
            case .text( let messageText):
                messages = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let currentUserEmail = UserDefaults.standard.value(forKey:"email") as? String else {
                completion(false)
                return
            }
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
            
            let newEntrymessage:[String:Any] = [
                "id":message.messageId,
                "type":message.kind.messageKindString,
                "content":messages,
                "date":dateString,
                "sender_email":safeEmail,
                "is_read":false,
                "name":name
            ]
            
            currentMessages.append(newEntrymessage)
            StrongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
                
            })
            
            
            
        }
        
    }
    
    //MARK:- Get all Exising Convo
    public func conversationExists(iwth targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)

        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseErrors.faildToFetch))
                return
            }

            // iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                // get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseErrors.faildToFetch))
                    return
                }
                completion(.success(id))
                return
            }

            completion(.failure(DatabaseErrors.faildToFetch))
            return
        })
    }
    
    
}







extension DatabaseManager {
    
    public func getDataFor(path:String, completion:@escaping(Result<Any,Error>)->Void){
        
        self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value  else {
                completion(.failure(DatabaseErrors.faildToFetch))
                return
            }
            completion(.success(value))
        }
    }
}



struct ChatAppUser{
    let firstName:String
    let lastName:String
    let emailAddress:String
    
    var validEmail:String {
        var  emailStr = emailAddress.replacingOccurrences(of:".", with: "-")
        emailStr = emailStr.replacingOccurrences(of: "@", with: "-")
        return emailStr
    }
    
    var  profilePictureFileName:String {
        return "\(validEmail)_profile_picture_png"
    }
}

