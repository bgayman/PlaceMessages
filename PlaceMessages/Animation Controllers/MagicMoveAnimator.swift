//
//  MagicMoveAnimator.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/14/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

// MARK: - Protocols
protocol MagicMoveFromViewControllerDataSource: class {
    var fromMagicView: UIImageView? { get }
}

protocol MagicMoveToViewControllerDataSource: class {
    var toMagicView: UIImageView { get }
    var chromeViews: [UIView] { get }
}

/// Animation controller that produces and animation where a view seems to magically move from one view to another
final class MagicMoveAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Types
    enum Direction {
        case up
        case down
    }
    
    // MARK: - Properties
    let isAppearing: Bool
    let duration: TimeInterval
    let direction: Direction
    
    // MARK: - Lifecycle
    init(isAppearing: Bool, duration: TimeInterval = 0.3, direction: Direction = .up) {
        self.direction = direction
        self.isAppearing =  isAppearing
        self.duration = duration
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isAppearing {
            animateOn(transitionContext)
        } else {
            animateOff(transitionContext)
        }
    }
    
    // MARK: - Animations
    func animateOn(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let container = transitionContext.containerView
        
        let fromDataSource: MagicMoveFromViewControllerDataSource
        if let navVC = fromVC as? UINavigationController,
              let fromDS = navVC.topViewController as? MagicMoveFromViewControllerDataSource {
            fromDataSource = fromDS
        }
        else if let splitVC = fromVC as? UISplitViewController,
            let navVC = splitVC.viewControllers.first as? UINavigationController,
            let fromDS = navVC.topViewController as? MagicMoveFromViewControllerDataSource {
            fromDataSource = fromDS
        }
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        guard let toDataSource = toVC as? MagicMoveToViewControllerDataSource else {
            transitionContext.completeTransition(false)
            return
        }
        
        toVC.view.alpha = 0.0
        let finalFrame = transitionContext.finalFrame(for: toVC)
        var frame = finalFrame
        frame.origin.y += direction == .up ? frame.size.height : -frame.size.height
        toVC.view.frame = frame
        toVC.view.layoutIfNeeded()
        container.addSubview(toVC.view)
        
        let backdrop = UIView(frame: toVC.view.frame)
        backdrop.backgroundColor = toVC.view.backgroundColor
        backdrop.alpha = 0.0
        container.addSubview(backdrop)
        toVC.view.backgroundColor = .clear
        
        let fromMagicView = fromDataSource.fromMagicView
        let toMagicView = toDataSource.toMagicView
        toDataSource.chromeViews.forEach { $0.alpha = 0.0}
        let snapshot = UIImageView(image: fromDataSource.fromMagicView?.image)
        snapshot.contentMode = .scaleAspectFit
        snapshot.clipsToBounds = true
        snapshot.backgroundColor = backdrop.backgroundColor
        let rect = container.convert(fromMagicView?.bounds ?? .zero, from: fromMagicView)
        snapshot.frame = rect
        container.addSubview(snapshot)
        
        fromMagicView?.isHidden = true
        toMagicView.isHidden = true
        
        UIView.animate(withDuration: duration, animations: {
            backdrop.alpha = 1.0
            toVC.view.alpha = 1.0
            toDataSource.chromeViews.forEach { $0.alpha = 1.0 }
            toVC.view.frame = finalFrame
            snapshot.frame = container.convert(toMagicView.bounds, from: toMagicView)
            
        }) { (finished) in
            toVC.view.backgroundColor = backdrop.backgroundColor
            backdrop.removeFromSuperview()
            
            fromMagicView?.isHidden = false
            toMagicView.isHidden = false
            snapshot.removeFromSuperview()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
            }
        }
    }
    
    func animateOff(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let container = transitionContext.containerView
        
        // Animating off so we need to reverse data sources
        guard let fromDataSource = fromVC as? MagicMoveToViewControllerDataSource else {
            transitionContext.completeTransition(false)
            return
        }
        
        let toDataSource: MagicMoveFromViewControllerDataSource
        if let navVC = toVC as? UINavigationController,
            let fromDS = navVC.topViewController as? MagicMoveFromViewControllerDataSource {
            toDataSource = fromDS
        }
        else if let splitVC = toVC as? UISplitViewController,
            let navVC = splitVC.viewControllers.first as? UINavigationController,
            let fromDS = navVC.topViewController as? MagicMoveFromViewControllerDataSource {
            toDataSource = fromDS
        }
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let fromMagicView = fromDataSource.toMagicView
        let toMagicView = toDataSource.fromMagicView
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        let backdrop = UIView(frame: fromVC.view.frame)
        backdrop.backgroundColor = fromVC.view.backgroundColor
        container.insertSubview(backdrop, belowSubview: fromVC.view)
        backdrop.alpha = 1.0
        fromVC.view.backgroundColor = .clear
        
        let snapshot = UIImageView(image: fromMagicView.image)
        snapshot.contentMode = fromMagicView.contentMode
        snapshot.clipsToBounds = true
        snapshot.frame = container.convert(fromMagicView.bounds, from: fromMagicView)
        container.addSubview(snapshot)
        
        var frame = finalFrame
        frame.origin.y += direction == .up ? frame.size.height : -frame.size.height
        
        toMagicView?.isHidden = true
        fromMagicView.isHidden = true
        
        UIView.animate(withDuration: duration, animations: {
            backdrop.alpha = 0
            fromDataSource.chromeViews.forEach { $0.alpha = 0.0 }
            fromVC.view.frame = frame
            snapshot.frame = container.convert(toMagicView?.bounds ?? .zero, from: toMagicView)
            toVC.view.alpha = 1.0
        }) { (_) in
            fromVC.view.backgroundColor = backdrop.backgroundColor
            backdrop.removeFromSuperview()
            snapshot.removeFromSuperview()
            fromDataSource.chromeViews.forEach { $0.alpha = 1.0 }
            
            fromMagicView.isHidden = false
            toMagicView?.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
            }
        }
    }
    
}
