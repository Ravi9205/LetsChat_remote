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
    public func fetchAllUsers(completion: @escaping(Result<[[String:String]],Error>)->Void){
        
        database.child("users").observeSingleEvent(of: .value) { dataSnapShot in
            
            guard let value = dataSnapShot.value as? [[String:String]] else {
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
        guard let currentEmail = UserDefaults.standard.value(forKey:"email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let refrence = database.child("\(safeEmail)")
        refrence.observeSingleEvent(of: .value) { snapShot in
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
            
            if var conversession = userNode["conversations"] as? [[String:Any]] {
                
                conversession.append(newConversationData)
                userNode["conversations"] = conversession
                refrence.setValue(userNode) { [weak self] error, _ in
                    
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name:name,conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    
                }
            }
            else
            {
                userNode["conversations"] = [
                    newConversationData
                ]
                refrence.setValue(userNode) {[weak self] error, _ in
                    
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(name:name,conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                }
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
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
            
        }
    }
    
    
    //MARK:- Fetching and returns all conversations
    public func getAllConversation(for email:String,completion:@escaping (Result<[Conversation],Error>)->Void){
        
        database.child("\(email)/conversations").observeSingleEvent(of: .value) { snapShot in
            
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
    public func getAllMessagesForConversation(with id:String, completion:@escaping(Result<String,Error>)->Void) {
        
    }
    //Send message to the target users
    public func sendMessage(to conversation:String,message:Message, completion:@escaping(Bool)->Void){
        
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

