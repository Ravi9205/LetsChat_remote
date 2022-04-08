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
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
    
}
extension MessageKind {
    var messageKindString:String {
        switch self {
            case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"

        case .photo(_):
            return "photo"

        case .video(_):
            return "video"

        case .location(_):
            return "location"

        case .emoji(_):
            return "emoji"

        case .audio(_):
            return "audio"

        case .contact(_):
            return "contact"

        case .linkPreview(_):
            return "linkPreview"

        case .custom(_):
            return "custom"

        }
    }
}
