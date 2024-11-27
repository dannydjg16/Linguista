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
    var speed: Float

    enum CodingKeys: String, CodingKey {
        case model
        case input
        case voice
        case speed
    }
}
