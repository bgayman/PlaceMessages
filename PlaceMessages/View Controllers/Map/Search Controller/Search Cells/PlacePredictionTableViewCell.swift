//
//  PlacePredictionTableViewCell.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacePredictionTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    var searchString: String?
    
    var attributedTitle: NSAttributedString? {
        guard let string = prediction?.attributedPrimaryText.string else { return nil }
        let attribString = NSMutableAttributedString(string: string, attributes: [NSAttributedStringKey.font: UIFont.appFont(textStyle: .headline, weight: .semibold)])
        let range = (string.lowercased() as NSString).range(of: searchString?.lowercased() ?? "")
        attribString.addAttribute(.foregroundColor, value: UIColor.appBlue, range: range)
        return attribString
    }
    
    var attributedDescription: NSAttributedString? {
        guard let string = prediction?.attributedSecondaryText?.string else { return nil }
        let attribString = NSMutableAttributedString(string: string, attributes: [NSAttributedStringKey.font: UIFont.appFont(textStyle: .subheadline, weight: .medium)])
        let range = (string.lowercased() as NSString).range(of: searchString?.lowercased() ?? "")
        attribString.addAttribute(.foregroundColor, value: UIColor.appBlue, range: range)
        return attribString
    }
    
    var prediction: GMSAutocompletePrediction? {
        didSet {
            titleLabel.attributedText = attributedTitle
            descriptionLabel.attributedText = prediction?.attributedSecondaryText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0.0, right: 0.0)
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.appFont(textStyle: .headline, weight: .semibold)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.appFont(textStyle: .subheadline, weight: .medium)
        separatorInset = UIEdgeInsets(top: 0, left: titleLabel.frame.minX, bottom: 0.0, right: 0.0)
    }

}
