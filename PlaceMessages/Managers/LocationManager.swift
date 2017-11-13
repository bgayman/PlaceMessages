//
//  LocationManager.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import CoreLocation

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    var currentLocation: CLLocationCoordinate2D?
    
    let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return locationManager
    }()
    
    override init() {
        super.init()
        self.setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
    }
    
    func getUserLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func stopUpdatingLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.stopUpdatingLocation()
        case .denied, .restricted, .notDetermined:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            NotificationCenter.default.post(name: .didUpdatedUserLocationAuthorization, object: nil)
        case .denied, .notDetermined, .restricted:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.currentLocation = location.coordinate
        NotificationCenter.default.post(name: .didUpdatedUserLocation, object: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
