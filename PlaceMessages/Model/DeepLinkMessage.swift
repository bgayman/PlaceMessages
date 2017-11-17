//
//  DeepLinkMessage.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

struct DeeplinkMessage {
    
    let date: Date
    let fromName: String
    let toName: String
    let placeID: String
    let placeName: String
    let messageType: Message.MessageType
    
    enum CodingKeys: String, CodingKey {
        case date
        case fromName
        case toName
        case placeID
        case placeName
        case messageType
    }
}

extension DeeplinkMessage {
    
    init?(urlComponents: URLComponents) {
        guard let queryItems = urlComponents.queryItems else { return nil }
        let dictionary = queryItems.reduce([String: String]()) { (result, queryItem) in
            var result = result
            result[queryItem.name] = queryItem.value?.removingPercentEncoding
            return result
        }
        guard let deeplinkMessage = DeeplinkMessage(dictionary: dictionary) else { return nil }
        self = deeplinkMessage
    }
    
    init?(dictionary: [String: String]) {
        guard let dateComponent = dictionary[CodingKeys.date.rawValue],
              let timeInterval = Double(dateComponent.removingPercentEncoding ?? ""),
              let fromName = dictionary[CodingKeys.fromName.rawValue],
              let toName = dictionary[CodingKeys.toName.rawValue],
              let placeID = dictionary[CodingKeys.placeID.rawValue],
              let placeName = dictionary[CodingKeys.placeName.rawValue],
              let messageTypeValue = dictionary[CodingKeys.messageType.rawValue],
              let messageType = Message.MessageType(rawValue: messageTypeValue) else { return nil }
        self.date = Date(timeIntervalSince1970: timeInterval)
        self.fromName = fromName
        self.toName = toName
        self.placeID = placeID
        self.placeName = placeName
        self.messageType = messageType
    }
    
    func isEqual(to message: Message) -> Bool {
        return abs(self.date.timeIntervalSince1970 - (message.date?.timeIntervalSince1970 ?? 0.0)) < 30 &&
               self.fromName == message.fromName &&
               self.toName == message.toName &&
               self.placeID == message.placeID &&
               self.messageType.rawValue == message.messageType &&
               self.placeName == message.placeName
    }
}
