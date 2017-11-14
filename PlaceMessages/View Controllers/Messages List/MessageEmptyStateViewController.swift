//
//  MessageEmptyStateViewController.swift
//  PlaceMessages
//
//  Created by B Gay on 11/14/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import GameplayKit

final class MessageEmptyStateViewController: UIViewController {
    
    // MARK: - Properties
    private let radius: CGFloat = 120.0
    private let cloudCount: Int = 8
    private let randomSource = GKARC4RandomSource()
    
    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - Lazy Init
    lazy private var imageView: UIImageView = {
        let image = UIImage(named: "icPaperPlane.png")!
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: image.size.width * -1, height: image.size.height * -1)
        self.view.addSubview(imageView)
        return imageView
    }()
    
    lazy private var clouds: [UIImageView] = {
        let clouds: [UIImageView] = Array(0..<self.cloudCount).map { _ in
            let image = UIImage(named: "icCloud")
            let imageView = UIImageView(image: image)
            return imageView
        }
        clouds.forEach { self.view.addSubview($0) }
        return clouds
    }()
    
    // MARK: - Computed Properties
    var path: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: view.bounds.minX, y: view.bounds.midY + radius))
        path.addLine(to: CGPoint(x: view.bounds.midX, y: view.bounds.midY + radius))
        path.addQuadCurve(to: CGPoint(x: view.bounds.midX + radius, y: view.bounds.midY), controlPoint: CGPoint(x: view.bounds.midX + radius, y: view.bounds.midY + radius))
        path.addQuadCurve(to: CGPoint(x: view.bounds.midX, y: view.bounds.midY - radius), controlPoint: CGPoint(x: view.bounds.midX + radius, y: view.bounds.midY - radius))
        path.addQuadCurve(to: CGPoint(x: view.bounds.midX - radius, y: view.bounds.midY), controlPoint: CGPoint(x: view.bounds.midX - radius, y: view.bounds.midY - radius))
        path.addQuadCurve(to: CGPoint(x: view.bounds.midX, y: view.bounds.midY + radius), controlPoint: CGPoint(x: view.bounds.midX - radius, y: view.bounds.midY + radius))
        path.addLine(to: CGPoint(x: view.bounds.maxX + radius, y: view.bounds.midY + radius))
        path.addLine(to: CGPoint(x: view.bounds.maxX + radius, y: view.bounds.maxY + radius))
        path.addLine(to: CGPoint(x: view.bounds.minX - radius, y: view.bounds.maxY + radius))
        path.addLine(to: CGPoint(x: view.bounds.minX - radius, y: view.bounds.midY + radius))
        path.close()
        return path
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        arrange(imageViews: clouds)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animate()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.appBlue
        imageView.isHidden = false
        clouds.forEach { $0.isHidden = false }
        
        view.bringSubview(toFront: titleLabel)
        view.bringSubview(toFront: descriptionLabel)
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.appFont(textStyle: .title1, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.layer.shadowOpacity = 0.25
        titleLabel.layer.shadowRadius = 30.0
        titleLabel.layer.shadowOffset = .zero
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.appFont(textStyle: .headline, weight: .semibold)
        descriptionLabel.textColor = .white
        descriptionLabel.layer.shadowOpacity = 0.25
        descriptionLabel.layer.shadowRadius = 30.0
        descriptionLabel.layer.shadowOffset = .zero
    }
    
    // MARK: - Animations
    private func animate() {
        
        let angle = CGFloat(CGFloat.pi / 16.0)
        
        imageView.layer.transform = CATransform3DMakeRotation(-angle, 0, 0, 1.0)
        
        let flight = CAKeyframeAnimation(keyPath: "position")
        flight.path = path.cgPath
        flight.duration = 15
        flight.repeatCount = Float.infinity
        flight.calculationMode = kCAAnimationPaced
        flight.rotationMode = kCAAnimationRotateAuto
        
        let wiggle = CABasicAnimation(keyPath: "transform.translation.y")
        wiggle.autoreverses = true
        wiggle.fromValue = 10
        wiggle.toValue = -10
        wiggle.duration = 0.8
        wiggle.repeatCount = Float.infinity
        wiggle.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let anim = CAAnimationGroup()
        anim.animations = [flight, wiggle]
        anim.duration = 15
        anim.fillMode = kCAFillModeForwards
        anim.repeatCount = Float.infinity
        anim.isRemovedOnCompletion = false
        imageView.layer.add(anim, forKey: "flight")
        
        animateClouds()
    }
    
    private func animateClouds() {
        clouds.forEach { (cloud) in
            let cloudWiggle = CABasicAnimation(keyPath: "transform.translation.y")
            cloudWiggle.autoreverses = true
            cloudWiggle.fromValue = 3
            cloudWiggle.toValue = -3
            cloudWiggle.duration = 2.0
            cloudWiggle.repeatCount = Float.infinity
            cloudWiggle.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            let travel = CABasicAnimation(keyPath: "transform.translation.x")
            travel.autoreverses = false
            travel.fromValue = 0
            travel.toValue = -view.bounds.width - view.bounds.width * 1.40
            travel.duration = 30
            travel.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            
            let anim = CAAnimationGroup()
            anim.animations = [travel, cloudWiggle]
            anim.duration = 30
            anim.repeatCount = Float.infinity
            anim.fillMode = kCAFillModeForwards
            anim.isRemovedOnCompletion = false
            cloud.layer.add(anim, forKey: "travel")
        }
    }
    
    private func arrange(imageViews: [UIImageView]) {
        for imageSubview in imageViews {
            let image = imageSubview.image ?? UIImage()
            let x: CGFloat = view.bounds.width + view.bounds.width * 1.33 * CGFloat(randomSource.nextUniform())
            let y: CGFloat = 20 + view.bounds.height * CGFloat(randomSource.nextUniform())
            let point = CGPoint(x: x, y: y)
            imageSubview.frame = CGRect(origin: point, size: image.size)
        }
    }
}
