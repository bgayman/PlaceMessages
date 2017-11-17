//
//  MessageListViewController.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import UIKit
import Contacts
import GooglePlaces
import MessageUI

class MessageListViewController: UIViewController, MessageSendable, ErrorHandleable {
    
    // MARK: - Properties
    private let viewModel: MessageListViewModel
    private let messageEmptyStateViewController = MessageEmptyStateViewController()
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyStateContainerView: UIView!
    
    // MARK: - Lazy Init
    lazy private var sendBarButtonItem: UIBarButtonItem = {
        let sendBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icSend"), style: .plain, target: self, action: #selector(self.didPressSend(_:)))
        return sendBarButtonItem
    }()
    
    // MARK: - Lifecycle
    init(contact: CNContact) {
        self.viewModel = MessageListViewModel(contact: contact)
        super.init(nibName: "\(MessageListViewController.self)", bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.appBeige
        
        let nib = UINib(nibName: "\(MessageTableViewCell.self)", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "\(MessageTableViewCell.self)")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        title = viewModel.title
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        navigationItem.rightBarButtonItem = sendBarButtonItem
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        add(childViewController: messageEmptyStateViewController, to: emptyStateContainerView, at: 0)
    }
    
    // MARK: - Actions
    @objc func didPressSend(_ sender: UIBarButtonItem) {
        let placeSearchViewController = PlaceSearchViewController()
        placeSearchViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: placeSearchViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = sender
        present(navigationController, animated: true)
    }
    
    // MARK: - Helpers
    func updateEmptyState() {
        let shouldShowEmptyState = viewModel.numberOfRowsInSection(MessageListViewModel.MessageListSections.received.rawValue) == 0 && viewModel.numberOfRowsInSection(MessageListViewModel.MessageListSections.sent.rawValue) == 0
        let alpha: CGFloat = shouldShowEmptyState ? 1.0 : 0.0
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.emptyStateContainerView?.alpha = alpha
        }
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource
extension MessageListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(MessageTableViewCell.self)", for: indexPath) as! MessageTableViewCell
        let message = viewModel.message(for: indexPath)
        cell.message = message
        cell.senderImageView.image = viewModel.senderImage(for: indexPath)
        cell.receiverImageView.image = viewModel.receiverImage(for: indexPath)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let placeID = viewModel.message(for: indexPath)?.placeID else { return }
        Router.show(.contacts(.messages(viewModel.contact, .place(placeID))))
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(for: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        view.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.10)
        view.textLabel?.textColor = UIColor.white
        view.textLabel?.font = UIFont.appFont(textStyle: .headline, weight: .semibold)
    }
}

// MARK: - MessageListViewModelDelegate
extension MessageListViewController: MessageListViewModelDelegate {
    
    func messageListViewModelDidUpdate(_ viewModel: MessageListViewModel) {
        updateEmptyState()
        tableView?.reloadData()
    }
    
    func messageListViewModel(_ viewModel: MessageListViewModel, didFailWith error: Error?) {
        updateEmptyState()
        handle(error)
    }
}

// MARK: - PlaceSearchViewControllerDelegate
extension MessageListViewController: PlaceSearchViewControllerDelegate {
    
    func placeSearchViewController(_ viewController: PlaceSearchViewController, didSelectPlace place: GMSPlace) {
        viewController.dismiss(animated: true) { [unowned self] in
            let (deepL, phoneN, em) = self.viewModel.makeMessage(place: place, contact: self.viewModel.contact)
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

// MARK: - MFMessageComposeViewControllerDelegate
extension MessageListViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
        viewModel.messageSendingDidFinish(with: result)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension MessageListViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        viewModel.messageSendingDidFinish(with: result)
    }
}
