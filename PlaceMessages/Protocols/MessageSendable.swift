//
//  MessageSendable.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import MessageUI

protocol MessageSendable: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    func send(deeplink: Deeplink, toPhoneNumber phoneNumber: String)
    func send(deeplink: Deeplink, toEmail email: String)
}

extension MessageSendable where Self: UIViewController {
    
    func send(deeplink: Deeplink, toPhoneNumber phoneNumber: String) {
        guard MFMessageComposeViewController.canSendText() else { return }
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        composeVC.recipients = [phoneNumber]
        composeVC.body = deeplink.url?.absoluteString ?? ""
        present(composeVC, animated: true)
    }
    
    func send(deeplink: Deeplink, toEmail email: String) {
        guard MFMailComposeViewController.canSendMail() else { return }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([email])
        composeVC.setMessageBody(deeplink.url?.absoluteString ?? "" , isHTML: false)
        present(composeVC, animated: true)
    }
}


