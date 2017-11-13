//
//  UserDefaults+Application.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    var userName: String? {
        return self.string(forKey: "userName")
    }
    
    func set(userName: String) {
        self.set(userName, forKey: "userName")
    }
    
}
