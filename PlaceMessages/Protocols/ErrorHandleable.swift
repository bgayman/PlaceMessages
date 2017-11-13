//
//  ErrorHandleable.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

protocol ErrorHandleable: class {
    
    func handle(_ error: Error?)
}

extension ErrorHandleable where Self: UIViewController {
    
    func handle(_ error: Error?) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        let alert = UIAlertController(error: error)
        alert.view.tintColor = UIColor.appBlue
        present(alert, animated: true)
    }
}
