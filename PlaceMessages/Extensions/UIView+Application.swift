//
//  UIView+Application.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

extension UIView {
    
    func shakeNo() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        self.transform = CGAffineTransform(translationX: 20.0, y: 0.0)
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: { [unowned self] in
            self.transform = .identity
        })
    }
}
