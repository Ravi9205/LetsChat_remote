//
//  StorageManager.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 05/04/22.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage()
    
    public typealias uploadProfilePcitureCompletion = (Result<String,Error>) ->Void
    
    //MARK:- Upload Profile Picture to the server
    public func uploadProfilePicture(with data:Data, fileName:String ,completion: @escaping uploadProfilePcitureCompletion) {
        
        storage.reference().child("images/\(fileName)").putData(data, metadata: nil) { meta, error in
            
            guard error == nil else {
                print("Failed to upload data to firebase for picture update ")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.reference().child("images/\(fileName)").downloadURL { url, error in
                
                guard let url = url else {
                    print("Failed to get downloaded URL")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    
                    return
                    
                }
                
                let urlString = url.absoluteString
                print("Downloaded URL Returned===\(urlString)")
                completion(.success(urlString))
                
            }
        }
    }
    
    public enum StorageErrors:Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    
}
