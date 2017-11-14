//
//  UINavigationController+StatusBar.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/13/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
