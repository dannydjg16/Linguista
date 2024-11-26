//
//  TtsRequest.swift
//  Linguista
//
//  Created by Daniel Grant on 11/25/24.
//

import Foundation

struct TtsRequest: Codable {
    var model: String
    var input: String
    var voice: String

    enum CodingKeys: String, CodingKey {
        case model
        case input
        case voice
    }
}
