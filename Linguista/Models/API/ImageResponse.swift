//
//  ImageResponse.swift
//  Linguista
//
//  Created by Daniel Grant on 10/22/26.
//

import Foundation

struct ImageResponse: Codable {
    var created: Int?
    var data: [ImageData]
}

struct ImageData: Codable {
    var b64Json: String?
    var url: String?
    var revisedPrompt: String?

    enum CodingKeys: String, CodingKey {
        case b64Json = "b64_json"
        case url
        case revisedPrompt = "revised_prompt"
    }
}
