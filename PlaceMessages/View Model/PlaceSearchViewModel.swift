//
//  PlaceSearchViewModel.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import GooglePlaces

protocol PlaceSearchViewModelDelegate: class {
    func searchViewModel(_ viewModel: PlaceSearchViewModel, didFailToUpdateWith error: Error?)
    func searchViewModel(_ viewModel: PlaceSearchViewModel, didUpdateWith predictions: [GMSAutocompletePrediction], from oldValue: [GMSAutocompletePrediction])
}

final class PlaceSearchViewModel: NSObject {
    
    // MARK: - Properties
    weak var delegate: PlaceSearchViewModelDelegate?
    
    var searchString: String? {
        didSet {
            guard let searchString = searchString, !searchString.isEmpty else {
                predictions = []
                return
            }
            fetchPlaces(for: searchString)
        }
    }
    
    var predictions = [GMSAutocompletePrediction]() {
        didSet {
            delegate?.searchViewModel(self, didUpdateWith: predictions, from: oldValue)
        }
    }
    
    var error: Error? {
        didSet {
            delegate?.searchViewModel(self, didFailToUpdateWith: error)
        }
    }
    
    // MARK: - Computed Properties
    private var mapBounds: GMSCoordinateBounds? {
        guard let currentLocation = LocationManager.shared.currentLocation else { return nil }
        let northEast = currentLocation.adjustedCoordinates(metersLatitude: 1_609, metersLongitude: 1_609)
        let southWest = currentLocation.adjustedCoordinates(metersLatitude: -1_609, metersLongitude: -1_609)
        return GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
    }
    
    // MARK: - Networking
    private func fetchPlaces(for searchText: String) {
        let filter = GMSAutocompleteFilter()
        NetworkActivityIndicatorManager.shared.incrementIndicatorCount()
        GMSPlacesClient.shared().autocompleteQuery(searchText, bounds: mapBounds, filter: filter) { (predictions, error) in
            NetworkActivityIndicatorManager.shared.decrementIndicatorCount()
            guard error == nil else {
                self.error = error
                return
            }
            if let predictions = predictions {
                self.predictions = predictions
            }
        }
    }
    
    func fetchPlace(for placeID: String, completion: @escaping (Result<GMSPlace?>) -> Void) {
        NetworkActivityIndicatorManager.shared.incrementIndicatorCount()
        GMSPlacesClient.shared().lookUpPlaceID(placeID) { (place, error) in
            NetworkActivityIndicatorManager.shared.decrementIndicatorCount()
            guard error == nil else {
                completion(.error(error: error!))
                return
            }
            completion(.success(response: place))
        }
    }
    
    // MARK: - List Handlers
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return predictions.count
    }
    
    func prediction(for indexPath: IndexPath) -> GMSAutocompletePrediction {
        return predictions[indexPath.row]
    }
}
