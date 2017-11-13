//
//  NotificationCenter+Closures.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

let keyboardWillShow = NotificationDescriptor(name: .UIKeyboardWillShow, parse: KeyboardShowPayload.init)
let keyboardWillHide = NotificationDescriptor(name: .UIKeyboardWillHide, parse: KeyboardShowPayload.init)

extension Notification.Name {
    static let didUpdatedUserLocation = Notification.Name("DidUpdatedUserLocationNotification")
    static let didUpdatedUserLocationAuthorization = Notification.Name("didUpdatedUserLocationAuthorization")
}

extension NotificationCenter {
    
    @objc static func when(_ name: Notification.Name, perform block: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main, using: block)
    }
}

extension NotificationCenter {
    @discardableResult
    func addObserver<A>(for descriptor: NotificationDescriptor<A>, object obj: Any?, queue: OperationQueue?, using block: @escaping (A) -> Void) -> NSObjectProtocol {
        return addObserver(forName: descriptor.name, object: obj, queue: queue) { (note) in
            block(descriptor.parse(note.userInfo!))
        }
    }
}

struct NotificationDescriptor<A> {
    let name: Notification.Name
    let parse: ([AnyHashable: Any]) -> A
}

struct KeyboardShowPayload {
    var beginFrame: CGRect
    let endFrame: CGRect
    let animationCurve: UIViewAnimationCurve
    let animationDuration: TimeInterval
    let isLocal: Bool
    
    init(userInfo: [AnyHashable: Any]) {
        self.beginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect
        self.endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let animationCurveRaw = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationCurve.RawValue
        self.animationCurve = UIViewAnimationCurve(rawValue: animationCurveRaw)!
        self.animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        self.isLocal = userInfo[UIKeyboardIsLocalUserInfoKey] as! Bool
    }
}
