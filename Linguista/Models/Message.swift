//
//  Message.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import Foundation
struct Message: Codable {
    var role: String?
    var content: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
}
