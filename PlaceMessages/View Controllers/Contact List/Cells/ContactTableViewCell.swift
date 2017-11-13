//
//  ContactTableViewCell.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import Contacts

class ContactTableViewCell: UITableViewCell {

    var contact: CNContact? {
        didSet {
            guard let contact = self.contact else { return }
            nameLabel.text = CNContactFormatter.string(from: contact, style: .fullName)
            emailLabel.text = ContactsManager.shared.email(for: contact)
            phoneLabel.text = ContactsManager.shared.phoneNumber(for: contact)
            if contact.imageDataAvailable,
               let data = contact.thumbnailImageData {
                contactImageView.image = UIImage(data: data)
            }
            else {
                contactImageView.image = #imageLiteral(resourceName: "icUser")
                contactImageView.tintColor = UIColor.appBlue
            }
        }
    }
    
    @IBOutlet private weak var contactImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let rect = self.convert(nameLabel.bounds, from: nameLabel)
        separatorInset = UIEdgeInsets(top: 0, left: rect.minX, bottom: 0, right: 0)
        contactImageView.layer.cornerRadius = contactImageView.bounds.height * 0.5
        contactImageView.layer.masksToBounds = true
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.appFont(textStyle: .headline, weight: .bold)
        phoneLabel.font = UIFont.appFont(textStyle: .subheadline, weight: .medium)
        emailLabel.font = UIFont.appFont(textStyle: .subheadline, weight: .medium)
    }

}
