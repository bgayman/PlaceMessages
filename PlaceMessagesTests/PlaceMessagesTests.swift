//
//  PlaceMessagesTests.swift
//  PlaceMessagesTests
//
//  Created by Brad G. on 11/11/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import XCTest
import Foundation
import GooglePlaces
import Contacts

@testable import PlaceMessages

class PlaceMessagesTests: XCTestCase {
    
    var deeplink: Deeplink?
    var nextDeeplink: Deeplink?
    var placesExpectation: XCTestExpectation?
    var contactsExpectation: XCTestExpectation?
    var searchExpectation: XCTestExpectation?
    var placeExpectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDeeplinkCreation() {
        let url = URL(string: "PlaceMessages://message?date=1510546713.55026&fromName=John%2520Doe&toName=Jane%2520Doe&placeID=ChIJA77QN9lfwokRRmMsefeNEbA&placeName=USTA%2520Billie%2520Jean%2520King%2520National%2520Tennis%2520Center&messageType=email")!
        deeplink = Deeplink(url: url)
        
        let nextURL = URL(string: "PlaceMessages://message?date=1510546713.55026&fromName=John%2520Doe&toName=Jane%2520Doe&placeID=ChIJA77QN9lfwokRRmMsefeNEbA&messageType=email")!
        nextDeeplink = Deeplink(url: nextURL)
        
        XCTAssertNotNil(deeplink, "deeplink must not be nil")
        XCTAssertNotNil(deeplink!.deeplinkMessage, "deeplink message must not be nil")
        
        XCTAssertNotNil(nextDeeplink, "nextDeeplink must not be nil")
        XCTAssertNil(nextDeeplink?.deeplinkMessage, "deeplink message must be nil")
    }
    
    func testDeeplinkParsing() {
        let url = URL(string: "PlaceMessages://message?date=1510546713.55026&fromName=John%2520Doe&toName=Jane%2520Doe&placeID=ChIJA77QN9lfwokRRmMsefeNEbA&placeName=USTA%2520Billie%2520Jean%2520King%2520National%2520Tennis%2520Center&messageType=email")!
        deeplink = Deeplink(url: url)
        
        XCTAssertEqual(deeplink?.deeplinkMessage?.toName, "Jane Doe", "deeplinkMessage toName must equal Jane Doe")
        XCTAssertEqual(deeplink?.deeplinkMessage?.placeID, "ChIJA77QN9lfwokRRmMsefeNEbA", "deeplinkMessage placeID must equal ChIJA77QN9lfwokRRmMsefeNEbA")
    }
    
    func testMapViewModel() {
        let mapViewModel = MapViewModel()
        mapViewModel.delegate = self
        placesExpectation = expectation(description: "load places from server.")
        waitForExpectations(timeout: 30.0) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testContactsViewModel() {
        let contactsViewModel = ContactListViewModel()
        contactsViewModel.delegate = self
        contactsExpectation = expectation(description: "Loading Contacts")
        waitForExpectations(timeout: 30.0) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testPlaceSearchViewModel() {
        let placeSearchViewModel = PlaceSearchViewModel()
        placeSearchViewModel.delegate = self
        placeSearchViewModel.searchString = "Brooklyn"
        searchExpectation = expectation(description: "Loading search")
        waitForExpectations(timeout: 30.0) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func testPlaceViewModel() {
        let placeViewModel = PlaceViewModel(placeID: "ChIJA77QN9lfwokRRmMsefeNEbA")
        placeViewModel.delegate = self
        placeExpectation = expectation(description: "Loading search")
        waitForExpectations(timeout: 30.0) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
}

extension PlaceMessagesTests: MapViewModelDelegate {
    func mapViewModel(_ viewModel: MapViewModel, didUpdatePlaces places: [GMSPlace]) {
        placesExpectation?.fulfill()
    }
    
    func mapViewModel(_ viewModel: MapViewModel, didFailUpdatingWith error: Error) {
        XCTFail("Loading places from server must not result in error. Error: \(error.localizedDescription)")
    }
}

extension PlaceMessagesTests: ContactListViewModelDelegate {
    
    func contactListViewModel(_ viewModel: ContactListViewModel, didUpdateContacts contacts: [CNContact]) {
        contactsExpectation?.fulfill()
    }
    
    func contactListViewModel(_ viewModel: ContactListViewModel, didFailToUpdateWith error: Error?) {
        XCTFail("Loading contacts must not result in error. Error: \(error?.localizedDescription ?? "error")")
    }
}

extension PlaceMessagesTests: PlaceSearchViewModelDelegate {
    func searchViewModel(_ viewModel: PlaceSearchViewModel, didFailToUpdateWith error: Error?) {
        XCTFail("Loading search results from server must not result in error. Error: \(error?.localizedDescription ?? "error")")
    }
    
    func searchViewModel(_ viewModel: PlaceSearchViewModel, didUpdateWith predictions: [GMSAutocompletePrediction], from oldValue: [GMSAutocompletePrediction]) {
        searchExpectation?.fulfill()
    }
}

extension PlaceMessagesTests: PlaceViewModelDelegate {
    func placeViewModel(_ viewModel: PlaceViewModel, didFailToUpdateWith error: Error?) {
         XCTFail("Loading place from server must not result in error. Error: \(error?.localizedDescription ?? "error")")
    }
    
    func placeViewModel(_ viewModel: PlaceViewModel, didUpdate place: GMSPlace?) {
        placeExpectation?.fulfill()
    }
    
    func placeViewModel(_ viewModel: PlaceViewModel, didUpdate image: UIImage?, metadata: GMSPlacePhotoMetadata?) {}
}


