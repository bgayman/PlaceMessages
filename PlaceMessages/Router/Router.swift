//
//  Router.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import Contacts

struct Router {
    
    static var isSmallerDevice: Bool {
        return splitViewController?.traitCollection.horizontalSizeClass != .regular || splitViewController?.traitCollection.verticalSizeClass != .regular
    }
    
    static var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    static var splitViewController: UISplitViewController? {
        guard let rootViewController = Router.appDelegate?.window?.rootViewController else { return nil }
        return rootViewController as? UISplitViewController
    }
    
    static var contactNavigationController: UINavigationController? {
        guard let viewController = splitViewController?.viewControllers.first else { return nil }
        return viewController as? UINavigationController
    }
    
    static var mapNavigationController: UINavigationController? {
        guard let viewController = splitViewController?.viewControllers.last else { return nil }
        return viewController as? UINavigationController
    }
    
    static func show(deeplink: Deeplink, animated: Bool = true) {
        guard let deeplinkMessage = deeplink.deeplinkMessage else { return }
        guard splitViewController?.presentedViewController == nil else {
            splitViewController?.presentedViewController?.dismiss(animated: animated) {
                show(deeplink: deeplink, animated: animated)
            }
            return
        }
        contactNavigationController?.popViewController(animated: animated)
        ContactsManager.shared.fetchContacts(with: deeplinkMessage.fromName) { (result) in
            switch result {
            case .error(let error):
                splitViewController?.handle(error)
            case .success(let contacts):
                guard let contact = contacts.first else { return }
                Router.show(.contacts(.messages(contact, .place(deeplinkMessage.placeID))))
            }
        }
    }
    
    static func show(_ destination: Destination, animated: Bool = true) {
        switch destination {
        case .username:
            let usernameViewController = UsernameViewController()
            usernameViewController.modalPresentationStyle = .fullScreen
            usernameViewController.modalPresentationCapturesStatusBarAppearance = true
            splitViewController?.present(usernameViewController, animated: animated)
        case .contacts(let destination):
            show(destination, animated: animated)
        case .map:
            let placesMapViewController = PlacesMapViewController.makeFromStoryboard()
            let navController = UINavigationController(rootViewController: placesMapViewController)
            splitViewController?.showDetailViewController(navController, sender: nil)
        case .place(let placeID):
            let placeDetailViewController = PlaceDetailViewController(placeID: placeID)
            let navigationController = UINavigationController(rootViewController: placeDetailViewController)
            navigationController.modalPresentationStyle = .pageSheet
            splitViewController?.present(navigationController, animated: true)
        }
    }
    
    static private  func show(_ destination: Destination.ContactsDestination, animated: Bool) {
        switch destination {
        case .map:
            let placesMapViewController = PlacesMapViewController.makeFromStoryboard()
            contactNavigationController?.pushViewController(placesMapViewController, animated: animated)
        case let .messages(contact, destination):
            Router.show(destination, contact: contact, animated: animated)
        }
    }
    
    static private func show(_ destination: Destination.MessagesDestination, contact: CNContact, animated: Bool) {
        switch destination {
        case .messages:
            let messageListViewController = MessageListViewController(contact: contact)
            contactNavigationController?.pushViewController(messageListViewController, animated: animated)
        case .place(let placeID):
            if contactNavigationController?.viewControllers.contains(where: { $0 is MessageListViewController }) == false {
                let messageListViewController = MessageListViewController(contact: contact)
                let placeDetailViewController = PlaceDetailViewController(placeID: placeID)
                var viewControllers = contactNavigationController?.viewControllers
                viewControllers?.append(contentsOf: [messageListViewController, placeDetailViewController])
                contactNavigationController?.setViewControllers(viewControllers ?? [], animated: animated)
            }
            else {
                let placeDetailViewController = PlaceDetailViewController(placeID: placeID)
                contactNavigationController?.pushViewController(placeDetailViewController, animated: animated)
            }
            
        }
    }
}

extension UISplitViewController: ErrorHandleable {}
