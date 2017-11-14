//
//  PlaceDetailViewController.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Contacts
import MessageUI

class PlaceDetailViewController: UIViewController, ErrorHandleable, MessageSendable {
    
    // MARK: - Types
    enum Appearance {
        case modally
        case embedded
    }
    
    // MARK: - Properties
    private let viewModel: PlaceViewModel
    private var image: UIImage?
    private var text: String?
    
    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var phoneNumber: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var labelStackView: UIStackView!
    @IBOutlet private weak var attributionLabel: UILabel!
    @IBOutlet private weak var mapView: GMSMapView!
    
    // MARK: - Lazy Init
    lazy private var sendBarButtonItem: UIBarButtonItem = {
        let sendBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icSend"), style: .plain, target: self, action: #selector(self.didPressSend(_:)))
        return sendBarButtonItem
    }()
    
    lazy var doneBarButtonItem: UIBarButtonItem = {
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.didPressDone(_:)))
        doneBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.appFont(textStyle: .headline, weight: .semibold)], for: .normal)
        return doneBarButtonItem
    }()
    
    // MARK: - Computed Properties
    var appearance: Appearance {
        if presentingViewController != nil {
            return .modally
        }
        return .embedded
    }
    
    // MARK: - Lifecycle
    init(placeID: String) {
        self.viewModel = PlaceViewModel(placeID: placeID)
        super.init(nibName: "\(PlaceDetailViewController.self)", bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.layer.cornerRadius = mapView.bounds.height * 0.5
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.appBeige
        
        navigationController?.navigationBar.barTintColor = UIColor.appBeige
        navigationController?.navigationBar.tintColor = UIColor.appRed
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .semibold, pointSize: 20.0)]
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        if appearance == .modally {
            navigationItem.leftBarButtonItem = doneBarButtonItem
        }
        
        labelStackView.arrangedSubviews.flatMap { $0 as? UILabel }.forEach { (label) in
            label.numberOfLines = 0
            label.isHidden = true
            label.text = nil
        }
        
        activityIndicator.startAnimating()
        
        nameLabel.font = UIFont.appFont(textStyle: .title2, weight: .bold)
        addressLabel.font = UIFont.appFont(textStyle: .headline, weight: .medium)
        phoneNumber.font = UIFont.appFont(textStyle: .subheadline, weight: .semibold)
        ratingLabel.font = UIFont.appFont(textStyle: .footnote, weight: .regular)
        attributionLabel.font = UIFont.appFont(textStyle: .body, weight: .regular)
        
        if let styleURL = viewModel.styleURL {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        }
        
        navigationItem.rightBarButtonItem = sendBarButtonItem
    }
    
    // MARK: - Helpers
    private func animateOn() {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.labelStackView.arrangedSubviews.flatMap { $0 as? UILabel }.forEach { (label) in
                label.isHidden = label.text?.isEmpty == true
            }
            self.view.layoutIfNeeded()
            self.mapView.alpha = 1.0
        }
    }
    
    private func show(_ markers: [GMSMarker]) {
        var bounds = GMSCoordinateBounds()
        for marker in markers {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds)
        mapView.animate(with: update)
    }
    
    // MARK: - Actions
    @objc func didPressSend(_ sender: UIBarButtonItem) {
        let contactListViewController = ContactListViewController.makeFromStoryboard()
        contactListViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: contactListViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = sender
        present(navigationController, animated: true)
    }
    
    @IBAction private func didTapImageView(_ sender: UITapGestureRecognizer) {
        let placeImageViewController = PlaceImageViewController(image: self.image, attributionText: self.text)
        placeImageViewController.transitioningDelegate = placeImageViewController
        placeImageViewController.modalPresentationStyle = .custom
        placeImageViewController.modalPresentationCapturesStatusBarAppearance = true
        present(placeImageViewController, animated: true)
    }
    
    @objc private func didPressDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension PlaceDetailViewController: ContactListViewControllerDelegate {
    func contactListViewController(_ viewController: ContactListViewController, didSelect contact: CNContact) {
        guard let place = viewModel.place else { return }
        viewController.dismiss(animated: true) { [unowned self] in
            let (deepL, phoneN, em) = self.viewModel.makeMessage(place: place, contact: contact)
            guard let deepLink = deepL else { return }
            if let phoneNumber = phoneN {
                self.send(deeplink: deepLink, toPhoneNumber: phoneNumber)
            }
            else if let email = em {
                self.send(deeplink: deepLink, toEmail: email)
            }
        }
    }
}

// MARK: - PlaceViewModelDelegate
extension PlaceDetailViewController: PlaceViewModelDelegate {
    
    func placeViewModel(_ viewModel: PlaceViewModel, didFailToUpdateWith error: Error?) {
        activityIndicator.stopAnimating()
        handle(error)
    }
    
    func placeViewModel(_ viewModel: PlaceViewModel, didUpdate place: GMSPlace?) {
        activityIndicator.stopAnimating()
        guard let place = place else { return }
        title = place.name
        nameLabel.text = place.name
        addressLabel.text = place.formattedAddress
        phoneNumber.text = place.phoneNumber
        ratingLabel.text = place.rating != 0.0 ? "Rating: \(place.rating)" : nil
        let marker = GMSMarker(place: place)
        marker.map = mapView
        animateOn()
        show([marker])
    }
    
    func placeViewModel(_ viewModel: PlaceViewModel, didUpdate image: UIImage?, metadata: GMSPlacePhotoMetadata?) {
        activityIndicator.stopAnimating()
        imageView.image = image
        imageView.isUserInteractionEnabled = image != nil
        self.image = image
        text = metadata?.attributions?.string
        attributionLabel.text = text
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension PlaceDetailViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
        viewModel.messageSendingDidFinish(with: result)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension PlaceDetailViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        viewModel.messageSendingDidFinish(with: result)
    }
}

// MARK: - MagicMoveFromViewControllerDataSource
extension PlaceDetailViewController: MagicMoveFromViewControllerDataSource {
    
    var fromMagicView: UIImageView? {
        return imageView
    }
}
