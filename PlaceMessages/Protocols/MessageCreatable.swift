//
//  MessageCreatable.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import MessageUI
import GooglePlaces
import Contacts

protocol MessageCreatable: class {
    
    var pendingMessage: Message? { get set }
    var error: Error? { get set }
    
    func saveToCoreData()
    func messageSendingDidFinish(with result: MFMailComposeResult)
    func messageSendingDidFinish(with result: MessageComposeResult)
    func makeMessage(place: GMSPlace, contact: CNContact) -> (Deeplink?, String?, String?)
}

extension MessageCreatable {
    
    func makeMessage(place: GMSPlace, contact: CNContact) -> (Deeplink?, String?, String?) {
        pendingMessage = Message(context: DataStore.shared.container.viewContext)
        pendingMessage?.date = Date()
        pendingMessage?.fromName = UserDefaults.standard.userName
        pendingMessage?.toName = CNContactFormatter.string(from: contact, style: .fullName)
        pendingMessage?.messageType = ContactsManager.shared.phoneNumber(for: contact) != nil ? Message.MessageType.text.rawValue : Message.MessageType.email.rawValue
        pendingMessage?.placeID = place.placeID
        pendingMessage?.placeName = place.name
        guard let message = pendingMessage else { return (nil, nil, nil) }
        let deeplink = Deeplink(message: message)
        return (deeplink, ContactsManager.shared.phoneNumber(for: contact), ContactsManager.shared.email(for: contact))
    }
    
    func messageSendingDidFinish(with result: MessageComposeResult) {
        switch result {
        case .cancelled, .failed:
            if let pendingMessage = pendingMessage {
                DataStore.shared.container.viewContext.delete(pendingMessage)
            }
        case .sent:
            saveToCoreData()
        }
    }
    
    func messageSendingDidFinish(with result: MFMailComposeResult) {
        switch result {
        case .cancelled, .failed, .saved:
            if let pendingMessage = pendingMessage {
                DataStore.shared.container.viewContext.delete(pendingMessage)
            }
        case .sent:
            saveToCoreData()
        }
    }
    
    func saveToCoreData() {
        do {
            try DataStore.shared.container.viewContext.save()
        }
        catch {
            self.error = error
        }
    }
    
}
