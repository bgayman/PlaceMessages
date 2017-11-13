//
//  Prediction.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/13/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import GooglePlaces

struct Prediction {
    
    let prediction: GMSAutocompletePrediction
}

extension Prediction: Hashable {
    
    var hashValue: Int {
        return prediction.placeID?.hashValue ?? 0
    }
}

extension Prediction: Equatable {
    
    static func == (lhs: Prediction, rhs: Prediction) -> Bool {
        return lhs.prediction.placeID == rhs.prediction.placeID && lhs.prediction.attributedFullText.string == rhs.prediction.attributedFullText.string && lhs.prediction.attributedSecondaryText?.string == rhs.prediction.attributedSecondaryText?.string
    }
}
