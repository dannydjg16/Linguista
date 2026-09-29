<div align="center">

<br/>

```
██╗     ██╗███╗   ██╗ ██████╗ ██╗   ██╗██╗███████╗████████╗ █████╗
██║     ██║████╗  ██║██╔════╝ ██║   ██║██║██╔════╝╚══██╔══╝██╔══██╗
██║     ██║██╔██╗ ██║██║  ███╗██║   ██║██║███████╗   ██║   ███████║
██║     ██║██║╚██╗██║██║   ██║██║   ██║██║╚════██║   ██║   ██╔══██║
███████╗██║██║ ╚████║╚██████╔╝╚██████╔╝██║███████║   ██║   ██║  ██║
╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
```

**Master any language. Anytime, anywhere.**

🔗 Backend API: [dannydjg16/linguista-api](https://github.com/dannydjg16/linguista-api)

[![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-147EFB?style=flat-square&logo=xcode&logoColor=white)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-brightgreen?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-blueviolet?style=flat-square)](CONTRIBUTING.md)

<br/>


</div>

---

## 🌍 About Linguista

**Linguista** is a beautifully crafted iOS language-learning app built entirely in Swift. Designed with native SwiftUI, it delivers an immersive and adaptive learning experience — from beginner vocabulary to advanced conversation practice — all from your iPhone or iPad.

Whether you're learning for travel, career, or curiosity, Linguista meets you where you are and takes you further.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🗂 **Smart Flashcards** | Spaced repetition system (SRS) that adapts to your memory curve |
| 🎙 **Pronunciation Coach** | Real-time speech recognition and phonetic feedback |
| 📖 **Story Mode** | Learn vocabulary in context through short, graded narratives |
| 🧠 **AI Conversation** | Practice natural dialogue with an intelligent conversation partner |
| 🔥 **Streak Tracker** | Daily goals and streak system to keep you motivated |
| 🌐 **30+ Languages** | From Spanish and Mandarin to Swahili and Norwegian |
| 🌙 **Offline Mode** | Download lesson packs and study without an internet connection |
| 📊 **Progress Dashboard** | Visual stats on vocabulary, fluency, and time spent |

---

## 🛠 Tech Stack

```
Linguista
├── UI Layer          → SwiftUI + UIKit (legacy components)
├── Architecture      → MVVM + Combine
├── Persistence       → Core Data + CloudKit sync
├── Networking        → URLSession + async/await
├── Speech            → AVFoundation + Speech Framework
├── AI Features       → OpenAI API / on-device Core ML
└── Testing           → XCTest + Swift Testing
```

- **Language:** Swift 5.9
- **Minimum Deployment:** iOS 17.0
- **UI Framework:** SwiftUI
- **Architecture:** MVVM with Combine reactive bindings
- **Database:** Core Data with iCloud sync via CloudKit
- **CI/CD:** GitHub Actions + Fastlane

---

## 🚀 Getting Started

### Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- Swift Package Manager (included with Xcode)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/linguista.git
   cd linguista
   ```

2. **Open in Xcode**
   ```bash
   open Linguista.xcodeproj
   ```

3. **Install dependencies**

   All dependencies are managed via Swift Package Manager. Xcode will resolve them automatically on first build. To resolve manually:
   ```bash
   # In Xcode: File → Packages → Resolve Package Versions
   ```

4. **Configure environment**

   Copy the example config file and add your API keys:
   ```bash
   cp Config.example.xcconfig Config.xcconfig
   ```
   Then edit `Config.xcconfig`:
   ```
   OPENAI_API_KEY = your_key_here
   ```

5. **Run the app**

   Select a simulator or device target in Xcode and press `⌘ + R`.

---

## 🧪 Testing

Run the full test suite from the command line:

```bash
xcodebuild test \
  -scheme Linguista \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -resultBundlePath TestResults.xcresult
```

Or press `⌘ + U` inside Xcode to run all tests.

---

## 🤝 Contributing

Contributions are warmly welcomed! Here's how to get involved:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for our code style guidelines, branch naming conventions, and PR checklist.

---

## 📋 Roadmap

- [ ] Apple Watch companion app
- [ ] Widgets for daily word-of-the-day
- [ ] Multiplayer vocabulary challenges
- [ ] Vision Pro immersive language environments
- [ ] Siri Shortcuts integration
- [ ] CarPlay support for audio lessons

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

---

## 🙏 Acknowledgements

- [Swift Algorithms](https://github.com/apple/swift-algorithms) — Efficient sequence algorithms
- [Nuke](https://github.com/kean/Nuke) — Image loading and caching
- All the language learners who inspired this project ❤️

---

<div align="center">

Made with ❤️ and Swift

[Report Bug](https://github.com/yourusername/linguista/issues) · [Request Feature](https://github.com/yourusername/linguista/issues) · [Join Discord](https://discord.gg/linguista)

</div>
