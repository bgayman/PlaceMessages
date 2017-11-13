//
//  DataStore.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import CoreData

final class DataStore: NSObject {
    
    // MARK: - Static Properties
    static let shared = DataStore()
    
    // MARK: - Properties
    let container: NSPersistentContainer
    
    // MARK: - Computed Properties
    
    // MARK: - Lifecycle
    override init() {
        container = NSPersistentContainer(name: "Messages")
        super.init()
        loadPersistentStores()
    }
    
    private func loadPersistentStores() {
        container.loadPersistentStores { [weak self] (storeDescription, error) in
            guard let strongSelf = self, error == nil else {
                print(error!)
                return
            }
            strongSelf.container.viewContext.automaticallyMergesChangesFromParent = true
            do {
                try strongSelf.container.viewContext.setQueryGenerationFrom(.current)
            }
            catch {
                print(error)
            }
        }
    }
    
    func add(_ deeplinkMessage: DeeplinkMessage) {
        container.performBackgroundTask { (moc) in
            let fetchRequest: NSFetchRequest<Message> = Message.receivedFetchRequest(for: deeplinkMessage.fromName)
            do {
                let existingMessages = try fetchRequest.execute()
                if existingMessages.first(where: deeplinkMessage.isEqual) == nil {
                    let message = Message(context: moc)
                    message.date = deeplinkMessage.date
                    message.fromName = deeplinkMessage.fromName
                    message.toName = deeplinkMessage.toName
                    message.placeID = deeplinkMessage.placeID
                    message.placeName = deeplinkMessage.placeName
                    message.messageType = deeplinkMessage.messageType.rawValue
                    try moc.save()
                }
            }
            catch {
                print(error)
            }
        }
        
    }
}

