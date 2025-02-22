//
//  NodeAPIError.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 2/15/25.
//

import Foundation

struct NodeAPIError: Error, Decodable {
    let error: String
}
