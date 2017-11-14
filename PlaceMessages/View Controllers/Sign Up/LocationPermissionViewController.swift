//
//  LocationPermissionViewController.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/13/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

class LocationPermissionViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nextButton: UIButton!
    
    // MARK: - Lazy Init
    lazy private var emitter: CAEmitterLayer = {
        let emitter = Emitter.make(with: [#imageLiteral(resourceName: "icWhiteMap"), #imageLiteral(resourceName: "icWhitePins")])
        emitter.frame = self.view.bounds
        emitter.emitterSize = CGSize(width: self.view.bounds.width * 2.0, height: 5.0)
        return emitter
    }()
    
    // MARK: - Computed Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emitter.frame = view.bounds
        emitter.emitterSize = CGSize(width: view.bounds.width * 2.0, height: 5.0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.appBlue
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.appFont(textStyle: .title1, weight: .bold)
        titleLabel.textColor = .white
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.appFont(textStyle: .headline, weight: .semibold)
        descriptionLabel.textColor = .white
        
        nextButton.backgroundColor = UIColor.white
        nextButton.titleLabel?.font = UIFont.appFont(textStyle: .title3, weight: .semibold)
        nextButton.layer.cornerRadius = 8.0
        nextButton.setTitleColor(UIColor.appRed, for: .normal)
        
        view.layer.addSublayer(emitter)
        
        imageView.tintColor = .white
    }
    
    private func setupNotifications() {
        NotificationCenter.when(.didUpdatedUserLocationAuthorization) { [weak self] (_) in
            self?.dismiss(animated: true)
        }
        
        NotificationCenter.when(.UIApplicationDidBecomeActive) { [weak self] (_) in
            if !LocationManager.shared.needsAuthorization {
                self?.didPressNext(self?.nextButton)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func didPressNext(_ sender: UIButton?) {
        LocationManager.shared.getUserLocation()
    }
}
