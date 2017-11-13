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
}

extension DeeplinkMessage {
    
    init?(urlComponents: URLComponents) {
        guard let queryItems = urlComponents.queryItems,
              let dateComponent = queryItems.first(where: { $0.name == "date" }),
              let fromNameComponent = queryItems.first(where: { $0.name == "fromName" }),
              let toNameComponent = queryItems.first(where: { $0.name == "toName" }),
              let placeIDComponent = queryItems.first(where: { $0.name == "placeID" }),
              let placeNameComponent = queryItems.first(where: { $0.name == "placeName" }),
              let messageTypeValueComponent = queryItems.first(where: { $0.name == "messageType" }),
              let timeInterval = Double(dateComponent.value?.removingPercentEncoding ?? ""),
              let fromName = fromNameComponent.value?.removingPercentEncoding,
              let toName = toNameComponent.value?.removingPercentEncoding,
              let placeID = placeIDComponent.value?.removingPercentEncoding,
              let placeName = placeNameComponent.value?.removingPercentEncoding,
              let messageTypeValue = messageTypeValueComponent.value?.removingPercentEncoding,
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
