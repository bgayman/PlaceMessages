//
//  GMSMarker+Place.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import GoogleMaps
import GooglePlaces

extension GMSMarker {
    
    convenience init(place: GMSPlace) {
        self.init()
        self.position = place.coordinate
        self.title = place.name
        self.snippet = place.formattedAddress
        self.icon = GMSMarker.markerImage(with: .appBlue)
    }
}
