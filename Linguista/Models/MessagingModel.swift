//
//  MessagingModel.swift
//  Linguista
//
//  Created by Daniel Grant on 8/20/24.
//

import Foundation

struct MessagingModel: Identifiable, Equatable {
    let id = UUID()
    let message: Message
    var isSentByUser: Bool
    var role: String
}
