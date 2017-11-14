//
//  PlaceImageViewController.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/14/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

class PlaceImageViewController: UIViewController {

    // MARK: - Properties
    private let image: UIImage?
    private let text: String?
    
    // MARK: - Outlets
    @IBOutlet private weak var attributionLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Lazy Inits
    lazy var dismissUpInteractiveController: PanInteractionController = {
        let dismissUpInteractiveController = PanInteractionController()
        dismissUpInteractiveController.panDirection = .up
        dismissUpInteractiveController.delegate = self
        return dismissUpInteractiveController
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    init(image: UIImage?, attributionText: String?) {
        self.image = image
        self.text = attributionText
        super.init(nibName: "\(PlaceImageViewController.self)", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateOnChrome(views: [closeButton, attributionLabel])
    }
    
    // MARK: - Setup
    private func setupUI() {
        imageView.image = image
        closeButton.transform = CGAffineTransform(translationX: 0, y: -100)
        attributionLabel.font = UIFont.appFont(textStyle: .body, weight: .regular)
        attributionLabel.textColor = .white
        attributionLabel.transform = CGAffineTransform(translationX: 0, y: 100)
        attributionLabel.text = text
        
        dismissUpInteractiveController.attach(to: view)
    }
    
    // MARK: - Actions
    @IBAction private func didPressClose(_ sender: UIButton) {
        animateOffChrome()
        dismiss(animated: true)
    }
    
    // MARK: - Animation
    private func animateOnChrome(views: [UIView]) {
        views.forEach {
            $0.isHidden = false
            $0.alpha = 1.0
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
            views.forEach {
                $0.transform = .identity
            }
        })
    }
    
    private func animateOffChrome() {
        animateOff([closeButton], transform: CGAffineTransform(translationX: 0, y: -100))
        animateOff([attributionLabel], transform: CGAffineTransform(translationX: 0, y: 100))
    }
    
    private func animateOff(_ views: [UIView], transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
            views.forEach { $0.transform = transform }
        }) { _ in
            views.forEach { $0.isHidden = true }
        }
    }
    
}

extension PlaceImageViewController: MagicMoveToViewControllerDataSource {
    
    var toMagicView: UIImageView {
        return imageView
    }
    
    var chromeViews: [UIView] {
        return [closeButton, attributionLabel]
    }
}

// MARK: - PanInteractionController
extension PlaceImageViewController: PanInteractionControllerDelegate {
    
    func interactiveAnimationDidStart(controller: PanInteractionController) {
        print(controller.panDirection)
        animateOffChrome()
        dismiss(animated: true)
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension PlaceImageViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MagicMoveAnimator(isAppearing: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissUpInteractiveController.isActive {
            return MagicMoveAnimator(isAppearing: false, direction: .down)
        }
        return MagicMoveAnimator(isAppearing: false)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if dismissUpInteractiveController.isActive {
            return dismissUpInteractiveController
        }
        return nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
