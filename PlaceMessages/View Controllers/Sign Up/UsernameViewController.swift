//
//  UsernameViewController.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.appBlue
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.appFont(textStyle: .title1, weight: .bold)
        titleLabel.textColor = .white
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.appFont(textStyle: .headline, weight: .semibold)
        descriptionLabel.textColor = .white
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont.appFont(textStyle: .callout, weight: .medium)])
        nameTextField.delegate = self
        nameTextField.textAlignment = .center
        nameTextField.font = UIFont.appFont(textStyle: .callout, weight: .medium)
        
        nextButton.backgroundColor = UIColor.white
        nextButton.titleLabel?.font = UIFont.appFont(textStyle: .title3, weight: .semibold)
        nextButton.layer.cornerRadius = 8.0
        nextButton.setTitleColor(UIColor.appRed, for: .normal)
    }
    
    @IBAction private func didPressNext(_ sender: UIButton) {
        let n = nameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let name = n, !name.isEmpty else {
            nameTextField.shakeNo()
            return
        }
        UserDefaults.standard.set(userName: name)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if ContactsManager.shared.needsToRequestAccess {
            Router.show(.signUp(.contacts))
        }
        else if LocationManager.shared.needsAuthorization {
            Router.show(.signUp(.location))
        }
        else {
            dismiss(animated: true)
        }
    }
    
}

extension UsernameViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didPressNext(nextButton)
        return true
    }
}
