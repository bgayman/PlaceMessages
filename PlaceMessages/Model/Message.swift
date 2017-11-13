//
//  Message.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import CoreData

@objc(Message)
class Message: NSManagedObject {
    
    enum MessageType: String {
        case email
        case text
    }
    
    static var entityName: String {
        return "\(Message.self)"
    }
    
    static func sentFetchRequest(for username: String) -> NSFetchRequest<Message> {
        let fetchRequest = NSFetchRequest<Message>(entityName: Message.entityName)
        fetchRequest.predicate = NSPredicate(format: "toName = %@", username)
        return fetchRequest
    }
    
    static func receivedFetchRequest(for username: String) -> NSFetchRequest<Message> {
        let fetchRequest = NSFetchRequest<Message>(entityName: Message.entityName)
        guard username != UserDefaults.standard.userName else {
            fetchRequest.predicate = NSPredicate(format: "fromName = %@ AND toName = %@", username, UserDefaults.standard.userName ?? "")
            return fetchRequest
        }
        fetchRequest.predicate = NSPredicate(format: "fromName = %@", username)
        return fetchRequest
    }
    
    var type: MessageType? {
        guard let messageType = MessageType(rawValue: messageType ?? "") else { return nil }
        return messageType
    }
}
