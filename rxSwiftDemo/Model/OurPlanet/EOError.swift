//
//  EOError.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 12/6/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation

enum EOError: Error {
    case invalidURL(String)
    case invalidParameter(String, Any)
    case invalidJSON(String)
}
