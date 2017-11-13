//
//  PlaceViewModel.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import GooglePlaces
import MessageUI

protocol PlaceViewModelDelegate: class {
    
    func placeViewModel(_ viewModel: PlaceViewModel, didFailToUpdateWith error: Error?)
    func placeViewModel(_ viewModel: PlaceViewModel, didUpdate place: GMSPlace?)
    func placeViewModel(_ viewModel: PlaceViewModel, didUpdate image: UIImage?, metadata: GMSPlacePhotoMetadata?)
}

final class PlaceViewModel: NSObject, MessageCreatable {
    
    private let placeID: String
    var pendingMessage: Message?
    weak var delegate: PlaceViewModelDelegate?
    
    var place: GMSPlace? {
        didSet {
            delegate?.placeViewModel(self, didUpdate: place)
        }
    }
    
    var error: Error? {
        didSet {
            delegate?.placeViewModel(self, didFailToUpdateWith: error)
        }
    }
    
    var styleURL: URL? {
        return Bundle.main.url(forResource: "Style", withExtension: "json")
    }
    
    var metadata: GMSPlacePhotoMetadata?
    
    var placeImage: UIImage? {
        didSet {
            delegate?.placeViewModel(self, didUpdate: placeImage, metadata: metadata)
        }
    }
    
    init(placeID: String) {
        self.placeID = placeID
        super.init()
        self.fetchPlace()
        self.fetchImage()
    }
    
    // MARK: - Networking
    private func fetchPlace() {
        NetworkActivityIndicatorManager.shared.incrementIndicatorCount()
        GMSPlacesClient.shared().lookUpPlaceID(placeID) { (place, error) in
            NetworkActivityIndicatorManager.shared.decrementIndicatorCount()
            guard error == nil else {
                self.error = error
                return
            }
            self.place = place
        }
    }
    
    private func fetchImage() {
        NetworkActivityIndicatorManager.shared.incrementIndicatorCount()
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (metadataList, error) in
            NetworkActivityIndicatorManager.shared.decrementIndicatorCount()
            guard error == nil else {
                self.error = error
                return
            }
            guard let metadata = metadataList?.results.first else { return }
            self.metadata = metadata
            NetworkActivityIndicatorManager.shared.incrementIndicatorCount()
            GMSPlacesClient.shared().loadPlacePhoto(metadata) { (image, error) in
                NetworkActivityIndicatorManager.shared.decrementIndicatorCount()
                guard error == nil else {
                    self.error = error
                    return
                }
                self.placeImage = image
            }
        }
    }
}
