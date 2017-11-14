//
//  ContactListViewController.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import Contacts

protocol ContactListViewControllerDelegate: class {
    func contactListViewController(_ viewController: ContactListViewController, didSelect contact: CNContact)
}

final class ContactListViewController: UIViewController, ErrorHandleable, StoryboardInitializable {

    // MARK: - Types
    enum Apperance {
        case modally
        case embedded
    }
    
    // MARK: - Properties
    weak var delegate: ContactListViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var mapBarButtonItem: UIBarButtonItem!
    
    // MARK: - Lazy Init
    lazy private var contactListViewModel: ContactListViewModel = {
        let contactListViewModel = ContactListViewModel()
        return contactListViewModel
    }()
    
    lazy var doneBarButtonItem: UIBarButtonItem = {
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.didPressDone(_:)))
        doneBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.appFont(textStyle: .headline, weight: .semibold)], for: .normal)
        return doneBarButtonItem
    }()
    
    // MARK: - Computed Properties
    var appearance: Apperance {
        if presentingViewController != nil {
            return .modally
        }
        return .embedded
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        contactListViewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.userName == nil || ContactsManager.shared.needsToRequestAccess || LocationManager.shared.needsAuthorization {
            Router.show(.signUp(.username))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if appearance == .embedded {
            navigationItem.rightBarButtonItem = Router.isSmallerDevice ? mapBarButtonItem : nil
        }
        else {
            navigationItem.rightBarButtonItem = Router.isSmallerDevice ? doneBarButtonItem : nil
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = contactListViewModel.title
        view.backgroundColor = UIColor.appBeige
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = UIColor.appBeige
        navigationController?.navigationBar.tintColor = UIColor.appRed
        
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .semibold, pointSize: 20.0)]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = appearance != .modally
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font: UIFont.appFont(weight: .black, pointSize: 40.0)]
            navigationController?.navigationItem.largeTitleDisplayMode = appearance == .modally ? .never : .always
        }
    }
    
    // MARK: - Actions
    @IBAction private func didPressMap(_ sender: UIBarButtonItem) {
        Router.show(.contacts(.map))
    }
    
    @objc private func didPressDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension ContactListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactListViewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ContactTableViewCell.self)", for: indexPath) as! ContactTableViewCell
        let contact = contactListViewModel.contact(for: indexPath)
        cell.contact = contact
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contactListViewModel.contact(for: indexPath)
        delegate?.contactListViewController(self, didSelect: contact)
        if appearance == .embedded {
            Router.show(.contacts(.messages(contact, .messages)))
        }
    }
}

// MARK: - ContactListViewModelDelegate
extension ContactListViewController: ContactListViewModelDelegate {
    
    func contactListViewModel(_ viewModel: ContactListViewModel, didUpdateContacts contacts: [CNContact]) {
        tableView.reloadData()
    }
    
    func contactListViewModel(_ viewModel: ContactListViewModel, didFailToUpdateWith error: Error?) {
        handle(error)
    }
}
