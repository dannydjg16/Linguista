//
//  MessagingModel.swift
//  Linguista
//
//  Created by Daniel Grant on 8/20/24.
//

import Foundation

struct MessagingModel: Identifiable, Equatable, Codable {
    let id = UUID()
    var message: Message
    var isSentByUser: Bool
    var audioData: Data?
    var translatedMessageContent: String?
    var translatedAudioData: Data?
    var transliteratedMessageContent: String?
    var translatedTransliteratedMessageContent: String?
}
