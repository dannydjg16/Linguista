//
//  Request.swift
//  Linguista
//
//  Created by Daniel Grant on 6/18/24.
//

import Foundation

struct CompletionsRequest: Codable {
    var model: String?
    var messages: [Message]?
    var temperature: Float
    var maxTokens: Int
    var topP: Int

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
        case topP = "top_p"
    }
}

struct Message: Codable {
    var role: String?
    var content: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
}
