//
//  PlaceSearchViewController.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import GooglePlaces

protocol PlaceSearchViewControllerDelegate: class {
    
    func placeSearchViewController(_ viewController: PlaceSearchViewController, didSelectPlace place: GMSPlace)
}

class PlaceSearchViewController: UIViewController, ErrorHandleable {
    
    // MARK: - Types
    enum Apperance {
        case modally
        case searchController
    }
    
    // MARK: - Properties
    weak var delegate: PlaceSearchViewControllerDelegate?
    
    // MARK: - Outlet
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    
    // MARK: - Lazy Init
    lazy var searchViewModel: PlaceSearchViewModel = {
        let searchViewModel = PlaceSearchViewModel()
        searchViewModel.delegate = self
        return searchViewModel
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.tintColor = .appRed
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]) ).defaultTextAttributes = [NSAttributedStringKey.font.rawValue: UIFont.appFont(weight: .medium, pointSize: 20.0)]
        (UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]) ).setTitleTextAttributes([NSAttributedStringKey.font: UIFont.appFont(weight: .regular, pointSize: 17.0)], for: .normal) 
        return searchController
    }()
    
    lazy var doneBarButtonItem: UIBarButtonItem = {
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.didPressDone(_:)))
        doneBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.appFont(textStyle: .headline, weight: .semibold)], for: .normal)
        return doneBarButtonItem
    }()
    
    // MARK: - Computed Property
    private var appearance: Apperance {
        if presentingViewController != nil {
            return .modally
        }
        return .searchController
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if appearance == .modally {
            navigationItem.rightBarButtonItem = Router.isSmallerDevice ? doneBarButtonItem : nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if appearance == .modally {
            searchController.isActive = true
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
        let imageView = UIImageView(image: #imageLiteral(resourceName: "powered_by_google_on_white"))
        imageView.contentMode = .scaleAspectFit
        tableView.tableFooterView = imageView
        let nib = UINib(nibName: "\(PlacePredictionTableViewCell.self)", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "\(PlacePredictionTableViewCell.self)")
        
        if appearance == .modally {
            visualEffectView.isHidden = true
            view.backgroundColor = UIColor.appBeige
            if #available(iOS 11.0, *) {
                navigationItem.searchController = searchController
            }
            else {
                navigationItem.titleView = searchController.searchBar
            }
            navigationController?.navigationBar.barTintColor = UIColor.appBeige
            navigationController?.navigationBar.tintColor = UIColor.appRed
        }
    }
    
    // MARK: - Actions
    @objc private func didPressDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension PlaceSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(PlacePredictionTableViewCell.self)", for: indexPath) as! PlacePredictionTableViewCell
        cell.searchString = searchViewModel.searchString
        cell.prediction = searchViewModel.prediction(for: indexPath)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let placeID = searchViewModel.prediction(for: indexPath).placeID else { return }
        if appearance == .modally {
            searchController.isActive = false
        }
        searchViewModel.fetchPlace(for: placeID) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .error(let error):
                strongSelf.handle(error)
            case .success(let place):
                guard let place = place else { return }
                strongSelf.delegate?.placeSearchViewController(strongSelf, didSelectPlace: place)
            }
        }
    }
}

// MARK: - PlaceSearchViewModelDelegate
extension PlaceSearchViewController: PlaceSearchViewModelDelegate {
    
    func searchViewModel(_ viewModel: PlaceSearchViewModel, didFailToUpdateWith error: Error?) {
        handle(error)
    }
    
    func searchViewModel(_ viewModel: PlaceSearchViewModel, didUpdateWith predictions: [GMSAutocompletePrediction], from oldValue: [GMSAutocompletePrediction]) {
        let newPredictions = predictions.map(Prediction.init)
        let oldPredictions = oldValue.map(Prediction.init)
        tableView.animateUpdate(oldDataSource: oldPredictions, newDataSource: newPredictions)
    }
}

// MARK: - UISearchResultsUpdating
extension PlaceSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchViewModel.searchString = searchController.searchBar.text
    }
}

extension PlaceSearchViewController: UISearchControllerDelegate {
    
    func didPresentSearchController(_ searchController: UISearchController) {
        if appearance == .modally {
            DispatchQueue.main.async {
                searchController.searchBar.becomeFirstResponder()
            }
        }
    }
}
