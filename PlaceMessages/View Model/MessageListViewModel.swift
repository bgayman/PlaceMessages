//
//  MessageListViewModel.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Contacts
import CoreData
import MessageUI
import GooglePlaces

protocol MessageListViewModelDelegate: class {
    func messageListViewModel(_ viewModel: MessageListViewModel, didFailWith error: Error?)
    func messageListViewModelDidUpdate(_ viewModel: MessageListViewModel)
}

final class MessageListViewModel: NSObject, MessageCreatable {

    // MARK: - Types
    enum MessageListSections: Int {
        case received
        case sent
        
        var title: String {
            switch self {
            case .received:
                return "Received"
            case .sent:
                return "Sent"
            }
        }
        
        static var all: [MessageListSections] {
            return [.received, .sent]
        }
    }
    
    // MARK: - Properties
    let contact: CNContact
    var currentUserContact: CNContact? {
        didSet {
            delegate?.messageListViewModelDidUpdate(self)
        }
    }
    private var sentMessagesFetchResultsController: NSFetchedResultsController<Message>?
    private var receivedMessagesFetchResultsController: NSFetchedResultsController<Message>?
    var error: Error? {
        didSet {
            
        }
    }
    var pendingMessage: Message?
    weak var delegate: MessageListViewModelDelegate?
    
    // MARK: - Computed Properties
    var title: String? {
        return name
    }
    
    private var name: String? {
        return ContactsManager.shared.fullName(for: contact)
    }
    
    var phoneNumber: String? {
        return ContactsManager.shared.phoneNumber(for: contact)
    }
    
    var email: String? {
        return ContactsManager.shared.email(for: contact)
    }
    
    // MARK: - Lifecycle
    init(contact: CNContact) {
        self.contact = contact
        super.init()
        loadFromCoreData()
        getCurrentUserContact()
    }
    
    private func loadFromCoreData() {
        let context = DataStore.shared.container.viewContext
        guard let name = name else { return }
        
        let sentFetchRequest: NSFetchRequest<Message> = Message.sentFetchRequest(for: name)
        sentFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        sentMessagesFetchResultsController = NSFetchedResultsController(fetchRequest: sentFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        sentMessagesFetchResultsController?.delegate = self
        
        let receivedFetchRequest: NSFetchRequest<Message> = Message.receivedFetchRequest(for: name)
        receivedFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        receivedMessagesFetchResultsController = NSFetchedResultsController(fetchRequest: receivedFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        receivedMessagesFetchResultsController?.delegate = self
        
        do {
            try sentMessagesFetchResultsController?.performFetch()
            try receivedMessagesFetchResultsController?.performFetch()
        }
        catch {
            self.error = error
        }
    }
    
    private func getCurrentUserContact() {
        guard let name = UserDefaults.standard.userName else { return }
        ContactsManager.shared.fetchContacts(with: name) { (result) in
            switch result {
            case .error:
                break
            case .success(let contacts):
                self.currentUserContact = contacts.first
            }
        }
    }
    
    // MARK: - List Handlers
    func numberOfSections() -> Int {
        return MessageListSections.all.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let section = MessageListSections(rawValue: section) else { return 0 }
        switch section {
        case .received:
            return receivedMessagesFetchResultsController?.sections?[0].numberOfObjects ?? 0
        case .sent:
            return sentMessagesFetchResultsController?.sections?[0].numberOfObjects ?? 0
        }
    }
    
    func message(for indexPath: IndexPath) -> Message? {
        guard let section = MessageListSections(rawValue: indexPath.section) else { return nil }
        switch section {
        case .received:
            let message = receivedMessagesFetchResultsController?.object(at: indexPath)
            return message
        case .sent:
            let message = sentMessagesFetchResultsController?.object(at: IndexPath(row: indexPath.row, section: 0))
            return message
        }
    }
    
    func title(for section: Int) -> String? {
        guard let section = MessageListSections(rawValue: section) else { return nil }
        return section.title
    }
    
    func senderImage(for indexPath: IndexPath) -> UIImage {
        guard let section = MessageListSections(rawValue: indexPath.section) else { return #imageLiteral(resourceName: "icUser") }
        switch section {
        case .received:
            guard let message = self.message(for: indexPath),
                  let name = message.fromName,
                  let image = ContactsManager.shared.imageCache[name] else { return #imageLiteral(resourceName: "icUser") }
            return image
        case .sent:
            guard let imageData = currentUserContact?.thumbnailImageData,
                  let image = UIImage(data: imageData) else { return #imageLiteral(resourceName: "icUser") }
            return image
        }
    }
    
    func receiverImage(for indexPath: IndexPath) -> UIImage {
        guard let section = MessageListSections(rawValue: indexPath.section) else { return #imageLiteral(resourceName: "icUser") }
        switch section {
        case .received:
            guard let imageData = currentUserContact?.thumbnailImageData,
                let image = UIImage(data: imageData) else { return #imageLiteral(resourceName: "icUser") }
            return image
        case .sent:
            guard let message = self.message(for: indexPath),
                  let name = message.toName,
                  let image = ContactsManager.shared.imageCache[name] else { return #imageLiteral(resourceName: "icUser") }
            return image
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension MessageListViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadFromCoreData()
        delegate?.messageListViewModelDidUpdate(self)
    }
}
