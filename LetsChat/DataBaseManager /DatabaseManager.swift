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
    
    
    
    //MARK:- Insert into dataBase
    public func insertUser(with user:ChatAppUser){
        
        database.child(user.validEmail).setValue(["first_name":user.firstName,"last_name":user.lastName
                                                   ])
    }
}



struct ChatAppUser{
    let firstName:String
    let lastName:String
    let emailAddress:String
    //let profilePictureURL:String
    
    var validEmail:String {
        var  emailStr = emailAddress.replacingOccurrences(of:".", with: "-")
        emailStr = emailStr.replacingOccurrences(of: "@", with: "-")
        return emailStr
    }
    
}
