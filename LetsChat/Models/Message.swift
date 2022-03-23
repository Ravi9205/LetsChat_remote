//
//  Message.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 22/03/22.
//

import Foundation
import MessageKit


struct Message: MessageType
{
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    
}
