//
//  CompletionsResponse.swift
//  Linguista
//
//  Created by Daniel Grant on 7/9/24.
//

import Foundation

struct CompletionsResponse: Codable {
    var id: String?
    var object: String?
    var created: Int
    var model: String?
    var choices: [Choice]?
    var usage: Usage?
    var systemFingerprint: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case choices
        case usage
        case systemFingerprint = "system_fingerprint"
    }
}

struct Choice: Codable, Hashable {
    var index: Int
    var message: Message
    var logProbs: String?
    var finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index
        case message
        case logProbs = "logprobs"
        case finishReason = "finish_reason"
    }
}

struct Usage: Codable, Hashable {
    var promptTokens: Int
    var completionTokens: Int
    var totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
