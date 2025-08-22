//
//  Constants.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import Foundation
import SwiftUI

// API endpoint url builders
let localBaseUrl = "https://localhost:7244"
let apiBaseUrl = "https://linguista-appservice.azurewebsites.net"
let completionsEndpoint = "/openai/completions"
let ttsEndpoint = "/openai/tts"

// Auth endpoint url builders
let authBaseUrl = "https://dev-7824301.okta.com/oauth2/default/v1"
let authTokenEndpoint = "/token"

// Language List
let popularLanguages = [
    "Farsi",
    "English",
    "Amharic",
    "Assamese",
    "Bengali",
    "Belarusian",
    "Bhojpuri",
    "Burmese",
    "Chewa",
    "Chhattisgarhi",
    "Chittagonian",
    "Croatian",
    "Czech",
    "Danish",
    "Deccan",
    "Dhundhari",
    "Dutch",
    "Eastern Min Chinese",
    "Eastern Punjabi",
    "Egyptian Arabic",
    "French",
    "German",
    "Greek",
    "Gujarati",
    "Hakka Chinese",
    "Haitian Creole",
    "Hausa",
    "Hungarian",
    "Indonesian",
    "Italian",
    "Japanese",
    "Javanese",
    "Jin Chinese",
    "Kannada",
    "Kazakh",
    "Khmer",
    "Korean",
    "Magahi",
    "Malagasy",
    "Malayalam",
    "Malaysian Sign Language",
    "Marathi",
    "Marwari",
    "Min Nan Chinese",
    "Nepali",
    "Northern Uzbek",
    "Odia (Oriya)",
    "Polish",
    "Portuguese",
    "Romanian",
    "Russian",
    "Saraiki",
    "Serbo-Croatian",
    "Sinhala",
    "Sinhalese",
    "Somali",
    "Southern Pashto",
    "Spanish",
    "Sundanese",
    "Sylheti",
    "Tagalog (Filipino)",
    "Tai Lue",
    "Tamil",
    "Telugu",
    "Thai",
    "Turkish",
    "Ukrainian",
    "Urdu",
    "Vietnamese",
    "Western Punjabi",
    "Wu Chinese",
    "Xiang Chinese",
    "Yoruba",
    "Yue Chinese",
    "Zhuang"
]

let popularLanguageObjects: [Language] = popularLanguages.enumerated().map { (index, name) in
    Language(id: index + 1, name: name)
}

let conversationStarters = [
    "What do you see around you right now?",
    "What did you do today?",
    "What are you doing tomorrow?",
    "How's your day going?",
    "How are you?",
    "What are you doing today?"
]
