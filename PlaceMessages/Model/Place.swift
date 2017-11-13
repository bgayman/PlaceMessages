//
//  Place.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/13/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import GooglePlaces

struct Place {
    
    let place: GMSPlace
}

extension Place: Hashable {
    
    var hashValue: Int {
        return place.placeID.hashValue
    }
}

extension Place: Equatable {
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.place.placeID == rhs.place.placeID && lhs.place.name == rhs.place.name && lhs.place.formattedAddress == rhs.place.formattedAddress
    }
}
