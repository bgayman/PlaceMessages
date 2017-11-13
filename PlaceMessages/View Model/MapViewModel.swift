//
//  MapViewModel.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import GooglePlaces
import GoogleMaps
import CoreLocation

protocol MapViewModelDelegate: class {
    func mapViewModel(_ viewModel: MapViewModel, didUpdatePlaces places:[GMSPlace])
    func mapViewModel(_ viewModel: MapViewModel, didFailUpdatingWith error: Error)
}

class MapViewModel: NSObject {
    
    // MARK: - Properties
    let title = "Places"
    weak var delegate: MapViewModelDelegate?
    
    private(set) var error: Error? {
        didSet {
            guard let error = error else { return }
            delegate?.mapViewModel(self, didFailUpdatingWith: error)
        }
    }
    
    private(set) var places = [GMSPlace]() {
        didSet {
            delegate?.mapViewModel(self, didUpdatePlaces: places)
        }
    }
    
    var styleURL: URL? {
        return Bundle.main.url(forResource: "Style", withExtension: "json")
    }
    
    var needsLocationAuthorization: Bool {
        return CLLocationManager.authorizationStatus() == .notDetermined
    }
        
    // MARK: - Lifecycle
    override init() {
        super.init()
        if !needsLocationAuthorization {
            fetchPlaces()
        }
        
        NotificationCenter.when(.didUpdatedUserLocationAuthorization) { [weak self] (_) in
            self?.fetchPlaces()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Networking
    private func fetchPlaces() {
        NetworkActivityIndicatorManager.shared.incrementIndicatorCount()
        GMSPlacesClient.shared().currentPlace { (placeLikelihoodList, error) in
            NetworkActivityIndicatorManager.shared.decrementIndicatorCount()
            if let error = error {
                self.error = error
            }
            if let placeLikelihoodList = placeLikelihoodList {
                self.places = placeLikelihoodList.likelihoods.map { $0.place }
            }
        }
    }
    
    // MARK: - Helpers
    func place(for marker: GMSMarker) -> GMSPlace? {
        return places.first(where: { $0.name == marker.title && $0.formattedAddress == marker.snippet })
    }
}

extension MapViewModel: PlaceSearchViewControllerDelegate {
    func placeSearchViewController(_ viewController: PlaceSearchViewController, didSelectPlace place: GMSPlace) {
        places = [place]
    }
}
