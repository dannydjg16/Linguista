//
//  ImageRequest.swift
//  Linguista
//
//  Created by Daniel Grant on 4/23/26.
//

import Foundation

struct ImageRequest: Codable {
    var model: String
    var prompt: String
    var size: String

    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case size
    }
}
