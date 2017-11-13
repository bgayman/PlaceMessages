//
//  CLLocationCoordinate2D+GooglePlaces.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import CoreLocation
import MapKit

extension CLLocationCoordinate2D {
    
    func adjustedCoordinates(metersLatitude: Double, metersLongitude: Double) -> CLLocationCoordinate2D {
        var tempCoord = self
        
        let tempRegion = MKCoordinateRegionMakeWithDistance(self, metersLatitude, metersLongitude)
        let tempSpan = tempRegion.span
        
        tempCoord.latitude = self.latitude + tempSpan.latitudeDelta
        tempCoord.longitude = self.longitude + tempSpan.longitudeDelta
        
        return tempCoord
    }
}
