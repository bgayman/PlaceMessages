//
//  ContactsManager.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Contacts
import UIKit

final class ContactsManager {
    
    // MARK: - Properties
    static let shared = ContactsManager()
    var imageCache = [String: UIImage]()
    private let contactStore = CNContactStore()
    
    // MARK: - Computed Properties
    var needsToRequestAccess: Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .notDetermined
    }
    
    // MARK: - Contact Store
    func requestAccess(completion: @escaping (Result<Bool>) -> Void) {
        if needsToRequestAccess {
            contactStore.requestAccess(for: .contacts) {(success, error) in
                DispatchQueue.main.async {
                    guard error == nil, success else {
                        completion(.error(error: error!))
                        return
                    }
                    completion(.success(response: success))
                }
            }
        }
    }
    
    func fetchAllContacts(completion: @escaping (Result<[CNContact]>) -> Void) {
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: self.contactStore.defaultContainerIdentifier())
        fetchContacts(matching: predicate, completion: completion)
    }
    
    func fetchContacts(with name: String, completion: @escaping (Result<[CNContact]>) -> Void) {
        let predicate = CNContact.predicateForContacts(matchingName: name)
        fetchContacts(matching: predicate, completion: completion)
    }
    
    private func fetchContacts(matching predicate: NSPredicate, completion: @escaping (Result<[CNContact]>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let keysToFetch = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactEmailAddressesKey,
                CNContactPhoneNumbersKey,
                CNContactImageDataAvailableKey,
                CNContactThumbnailImageDataKey,
                ] as? [CNKeyDescriptor]
            do {
                let results = try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch ?? [])
                DispatchQueue.main.async {
                    completion(.success(response: results))
                }
                for contact in results.filter(self.contactHasEmailOrPhone) {
                    if let data = contact.thumbnailImageData {
                        self.imageCache[self.fullName(for: contact)] = UIImage(data: data)
                    }
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.error(error: error))
                }
            }
        }
    }
    
    // MARK: - Helpers
    func email(for contact: CNContact) -> String? {
        return contact.emailAddresses.first(where: { ($0.label ?? "") == CNLabelHome })?.value as String?
    }
    
    func phoneNumber(for contact: CNContact) -> String? {
        return contact.phoneNumbers.first(where: { ($0.label ?? "") == CNLabelHome })?.value.stringValue as String?
    }
    
    func fullName(for contact: CNContact) -> String {
        return CNContactFormatter.string(from: contact, style: .fullName) ?? ""
    }
    
    private func contactHasEmailOrPhone(_ contact: CNContact) -> Bool {
        return contact.emailAddresses.first(where: { ($0.label ?? "") == CNLabelHome }) != nil ||
            contact.phoneNumbers.first(where: { ($0.label ?? "") == CNLabelHome }) != nil
    }
}
