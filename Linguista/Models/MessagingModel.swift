//
//  MessagingModel.swift
//  Linguista
//
//  Created by Daniel Grant on 8/20/24.
//

import Foundation

struct MessagingModel: Identifiable, Equatable {
    let id = UUID()
    var message: Message
    var isSentByUser: Bool
    var audioData: Data?
}
