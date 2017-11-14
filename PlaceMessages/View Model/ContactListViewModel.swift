//
//  ContactListViewModel.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Contacts

protocol ContactListViewModelDelegate: class {
    func contactListViewModel(_ viewModel: ContactListViewModel, didUpdateContacts contacts: [CNContact])
    func contactListViewModel(_ viewModel: ContactListViewModel, didFailToUpdateWith error: Error?)
}

final class ContactListViewModel: NSObject {
    
    // MARK: - Properties
    let title = "Contacts"
    weak var delegate: ContactListViewModelDelegate?
    
    private var error: Error? {
        didSet {
            self.delegate?.contactListViewModel(self, didFailToUpdateWith: self.error)
        }
    }
    
    private var contacts = [CNContact]() {
        didSet {
            self.delegate?.contactListViewModel(self, didUpdateContacts: self.contacts)
        }
    }
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        if !ContactsManager.shared.needsToRequestAccess {
            self.fetchContacts()
        }
        else {
            NotificationCenter.when(.didUpdatedUserContactsAuthorization) { [weak self] (_) in
                self?.fetchContacts()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Contacts Store
    private func fetchContacts() {
        ContactsManager.shared.fetchAllContacts { (result) in
            switch result {
            case .error(let error):
                self.error = error
            case .success(let contacts):
                self.contacts = contacts.filter(self.contactHasEmailOrPhone)
                                        .sorted { $0.givenName < $1.givenName }
            }
        }
    }
    
    func requestAccess() {
        ContactsManager.shared.requestAccess { (result) in
            switch result {
            case .error(let error):
                self.error = error
            case .success:
                self.fetchContacts()
            }
        }
    }
    
    
    // MARK: - List Handlers
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return contacts.count
    }
    
    func contact(for indexPath: IndexPath) -> CNContact {
        return contacts[indexPath.row]
    }
    
    func contactHasEmailOrPhone(_ contact: CNContact) -> Bool {
        return contact.emailAddresses.first(where: { ($0.label ?? "") == CNLabelHome }) != nil ||
               contact.phoneNumbers.first(where: { ($0.label ?? "") == CNLabelHome }) != nil
    }
}
