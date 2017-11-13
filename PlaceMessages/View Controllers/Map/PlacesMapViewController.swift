//
//  PlacesMapViewController.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

final class PlacesMapViewController: UIViewController, ErrorHandleable, StoryboardInitializable {
    
    // MARK: - Lazy Init
    lazy private var viewModel: MapViewModel = {
        return MapViewModel()
    }()
    
    lazy var searchController: UISearchController = {
        let placeSearchViewController = PlaceSearchViewController()
        placeSearchViewController.delegate = self.viewModel
        let searchController = UISearchController(searchResultsController: placeSearchViewController)
        searchController.searchResultsUpdater = placeSearchViewController
        searchController.searchBar.tintColor = .appRed
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]) ).defaultTextAttributes = [NSAttributedStringKey.font.rawValue: UIFont.appFont(weight: .medium, pointSize: 20.0)]
        return searchController
    }()
    
    // MARK: - Outlets
    @IBOutlet private weak var mapView: GMSMapView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupUI()
        
        NotificationCenter.when(.didUpdatedUserLocationAuthorization) { [weak self] (_) in
            self?.mapView.isMyLocationEnabled = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = viewModel.title
        mapView.delegate = self
        
        navigationController?.navigationBar.barTintColor = UIColor.appBeige
        navigationController?.navigationBar.tintColor = UIColor.appRed
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .semibold, pointSize: 20.0)]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .never
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController = searchController
        }
        else {
            navigationItem.titleView = searchController.searchBar
        }
        
        if let styleURL = viewModel.styleURL {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        }
        
        if !viewModel.needsLocationAuthorization {
            mapView.isMyLocationEnabled = true
        }
    }
    
    // MARK: - Helpers
    private func show(_ markers: [GMSMarker]) {
        var bounds = GMSCoordinateBounds()
        for marker in markers {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds)
        mapView.animate(with: update)
    }
}

// MARK: - MapViewModelDelegate
extension PlacesMapViewController: MapViewModelDelegate {
    
    func mapViewModel(_ viewModel: MapViewModel, didUpdatePlaces places: [GMSPlace]) {
        searchController.isActive = false
        mapView.clear()
        let markers = places.map(GMSMarker.init)
        markers.forEach { $0.map = mapView }
        show(markers)
    }
    
    func mapViewModel(_ viewModel: MapViewModel, didFailUpdatingWith error: Error) {
        handle(error)
    }
}

// MARK: - GMSMapViewDelegate
extension PlacesMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let place = viewModel.place(for: marker) else { return }
        Router.show(.place(place.placeID))
    }
}
