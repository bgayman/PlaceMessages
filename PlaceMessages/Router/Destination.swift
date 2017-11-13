//
//  Destination.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation
import Contacts

enum Destination {
    
    case username
    case contacts(ContactsDestination)
    case map
    case place(String)
    
    enum ContactsDestination {
        case map
        case messages(CNContact, MessagesDestination)
    }
    
    enum MessagesDestination {
        case messages
        case place(String)
    }
}
