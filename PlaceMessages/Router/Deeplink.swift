//
//  Deeplink.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

struct Deeplink {
    
    // MARK: - Properties
    let urlComponents: URLComponents
    
    // MARK: - Computed Properties
    var url: URL? {
        return urlComponents.url
    }
    
    var universalLink: URL? {
        var universalComponents = URLComponents()
        universalComponents.scheme = "https"
        universalComponents.host = "kitura-starter-pseudocorneous-aardwolf.mybluemix.net"
        universalComponents.queryItems = urlComponents.queryItems
        return universalComponents.url
    }
    
    var deeplinkMessage: DeeplinkMessage? {
        return DeeplinkMessage(urlComponents: urlComponents)
    }
    
    var messageText: String {
        return [universalLink?.absoluteString, url?.absoluteString].flatMap { $0 }.joined(separator: "\n\n")
    }
    
    // MARK: - Lifecycle
    init?(url: URL) {
        guard let urlComponents = URLComponents(string: url.absoluteString) else { return nil }
        self.urlComponents = urlComponents
    }
    
    init(message: Message) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "PlaceMessages"
        urlComponents.host = "message"
        let dateQueryItem = URLQueryItem(name: "date", value: "\(message.date?.timeIntervalSince1970 ?? 0)")
        let fromNameQueryItem = URLQueryItem(name: "fromName", value: message.fromName?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        let toNameQueryItem = URLQueryItem(name: "toName", value: message.toName?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        let placeQueryItem = URLQueryItem(name: "placeID", value: message.placeID?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        let placeNameQueryItem = URLQueryItem(name: "placeName", value: message.placeName?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        let messageTypeQueryItem = URLQueryItem(name: "messageType", value: message.messageType?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        urlComponents.queryItems = [dateQueryItem, fromNameQueryItem, toNameQueryItem, placeQueryItem, placeNameQueryItem, messageTypeQueryItem]
        self.urlComponents = urlComponents
    }
}
