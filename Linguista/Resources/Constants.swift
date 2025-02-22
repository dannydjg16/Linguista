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

let conversationPrompts: [String] = [
    "Having a lesson with a language tutor",
    "Ordering at a restaurant",
    "Meeting someone for the first time",
    "Asking for directions",
    "Checking into a hotel"
]

let conversationPromptObjects: [Prompt] = conversationPrompts.enumerated().map { (index, name) in
    Prompt(id: index + 1, name: name)
}

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
    "How's your day going?",
    "What's new in your world?",
    "Seen any good shows lately?",
    "What's your favorite book or movie?",
    "Any exciting plans for the weekend?",
    "What's something you're passionate about?",
    "What's your favorite travel memory?",
    "What's your favorite type of music?",
    "What's the best meal you've had recently?",
    "What's your favorite thing about your hometown?",
    "What's your favorite holiday?",
    "What's something you're looking forward to in the future?",
    "What's your favorite way to spend a day off?",
    "What's your favorite animal?",
    "What's your favorite sport?",
    "What's your favorite thing about yourself?",
    "What's your favorite quote?",
    "What's your favorite season?",
    "What's your favorite thing to do in your free time?",
    "What's your favorite memory from childhood?",
    "What's your favorite way to relax?",
    "What's your favorite thing about your career?",
    "What's your favorite thing to eat?",
    "What's your favorite thing to do on a rainy day?",
    "What's your favorite thing to do with friends?",
    "What's your favorite thing to do with family?",
    "What's your favorite thing to do with pets?",
    "What's your favorite thing to do with your partner?"
]
