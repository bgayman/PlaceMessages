//
//  UIViewController+ChildViewController.swift
//  PlaceMessages
//
//  Created by B Gay on 11/14/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func add(childViewController: UIViewController, to view: UIView, at index: Int) {
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(childViewController)
        childViewController.view.frame = view.bounds
        view.insertSubview(childViewController.view, at: index)
        childViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        childViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        childViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        childViewController.view.layoutIfNeeded()
        childViewController.didMove(toParentViewController: self)
    }
    
    func remove(childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: nil)
        childViewController.removeFromParentViewController()
        childViewController.view.removeFromSuperview()
    }
}
