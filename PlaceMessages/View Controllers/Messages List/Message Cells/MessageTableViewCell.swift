//
//  MessageTableViewCell.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

final class MessageTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
    
    var message: Message? {
        didSet {
            fromLabel.text = message?.fromName
            toLabel.text = message?.toName
            placeNameLabel.text = message?.placeName
            if let date = message?.date {
                dateLabel.text = MessageTableViewCell.dateFormatter.string(from: date)
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var fromLabel: UILabel!
    @IBOutlet private weak var toLabel: UILabel!
    @IBOutlet private weak var sentIconImageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var placeNameLabel: UILabel!
    @IBOutlet weak var receiverImageView: UIImageView!
    @IBOutlet weak var senderImageView: UIImageView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateLabel.font = UIFont.appFont(textStyle: .caption1, weight: .regular)
        dateLabel.textColor = UIColor.lightGray
        
        placeNameLabel.numberOfLines = 0
        placeNameLabel.font = UIFont.appFont(textStyle: .subheadline, weight: .semibold)
        placeNameLabel.textColor = UIColor.appGreen
        
        fromLabel.numberOfLines = 0
        fromLabel.font = UIFont.appFont(textStyle: .body, weight: .medium)
        
        toLabel.numberOfLines = 0
        toLabel.font = UIFont.appFont(textStyle: .body, weight: .medium)
        
        sentIconImageView.tintColor = UIColor.appYellow
        
        senderImageView.tintColor = UIColor.appBlue
        senderImageView.layer.cornerRadius = senderImageView.bounds.height * 0.5
        senderImageView.layer.masksToBounds = true
        
        receiverImageView.tintColor = UIColor.appBlue
        receiverImageView.layer.cornerRadius = senderImageView.bounds.height * 0.5
        receiverImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
    }
}
