//
//  Message.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import Foundation

struct Message: Codable, Hashable {
    var role: String
    var content: String
    var additionalContent: String
}
