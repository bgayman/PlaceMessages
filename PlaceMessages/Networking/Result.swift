//
//  Result.swift
//  PlaceMessages
//
//  Created by Brad G. on 11/12/17.
//  Copyright © 2017 Brad G. All rights reserved.
//

import Foundation

/// Enum that represents possible network response
enum Result<T> {
    case error(error: Error)
    case success(response: T)
}
