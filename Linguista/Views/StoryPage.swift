//
//  StoryPage.swift
//  Linguista
//
//  Created by Daniel Grant on 4/6/26.
//


import SwiftUI

// https://claude.ai/chat/e5d5f890-b027-4615-87d7-62885cda1959

// MARK: - API Protocol (swap this implementation out for your real API)

protocol StoryAPIService {
    func generateFirstSentence(prompt: String) async throws -> StoryPage
    func generateNextSentence(previousPages: [StoryPage]) async throws -> StoryPage
}

// MARK: - Fake API (pre-filled with sample data — replace with real implementation)

class FakeStoryAPIService: StoryAPIService {

    // Simulated delay to mimic a real network call
    private let simulatedDelay: UInt64 = 1_000_000_000 // 1 second

    private let fakeSentences = [
        "Once upon a time, in a forest where the trees whispered secrets to those who listened, a small fox discovered a glowing door hidden beneath the oldest oak.",
        "The door opened with a soft chime, revealing a swirling tunnel of amber light that smelled faintly of cinnamon and rain.",
        "On the other side stood a village made entirely of books — their pages forming cobblestone streets, their spines rising as chimneys.",
        "A tiny librarian mouse greeted the fox with a bow and offered a map drawn in invisible ink that only appeared when held up to starlight.",
        "Together they followed the map through a meadow of floating lanterns, each one holding a story no one had ever told.",
        "At the meadow's edge they found the Source — a silver spring whose waters flowed with pure imagination, waiting to be sipped.",
    ]

    private let fakeImagePrompts = [
        "A glowing magical door hidden beneath an ancient oak tree in a misty forest, fantasy art style",
        "A swirling tunnel of amber light and warm tones, whimsical illustration",
        "A charming village built entirely from books, cobblestone streets made of pages, soft watercolor style",
        "A tiny mouse librarian bowing to a fox, holding a glowing map, storybook illustration",
        "A meadow full of floating glowing lanterns at twilight, magical realism art",
        "A silver spring glowing with ethereal light in an enchanted forest clearing, fantasy painting",
    ]

    func generateFirstSentence(prompt: String) async throws -> StoryPage {
        try await Task.sleep(nanoseconds: simulatedDelay)
        return StoryPage(
            sentence: fakeSentences[0],
            imageURL: nil, // Replace with actual image URL/data from your API
            imagePrompt: fakeImagePrompts[0]
        )
    }

    func generateNextSentence(previousPages: [StoryPage]) async throws -> StoryPage {
        try await Task.sleep(nanoseconds: simulatedDelay)
        let index = min(previousPages.count, fakeSentences.count - 1)
        return StoryPage(
            sentence: fakeSentences[index],
            imageURL: nil,
            imagePrompt: fakeImagePrompts[index]
        )
    }
}

struct StoryPromptView: View {
    @ObservedObject var viewModel: StoryViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                    )
                    .symbolEffect(.pulse)

                Text("Create a story prompt\nto get your story started")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("Describe a character, a place, or a feeling — let imagination do the rest.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Prompt input
            VStack(alignment: .leading, spacing: 8) {
                Text("Your prompt")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.leading, 4)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isFocused ? Color.purple.opacity(0.6) : Color.white.opacity(0.15), lineWidth: 1)
                        )

                    if viewModel.promptText.isEmpty {
                        Text("e.g. A young inventor who finds a map in her grandmother's attic…")
                            .foregroundStyle(.white.opacity(0.3))
                            .font(.system(size: 15, design: .rounded))
                            .padding(16)
                    }

                    TextEditor(text: $viewModel.promptText)
                        .focused($isFocused)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(.white)
                        .font(.system(size: 15, design: .rounded))
                        .frame(minHeight: 100, maxHeight: 150)
                        .padding(12)
                }
            }
            .padding(.horizontal)

            // Error message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.8))
                    .padding(.horizontal)
            }

            // Start button
            Button {
                isFocused = false
                Task {
                    withAnimation(.spring()) {
                        _ = viewModel.isLoading
                    }
                    await viewModel.startStory()
                }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "wand.and.stars")
                        Text("Begin the Story")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(colors: [Color("7b2fff"), Color("3b82f6")],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .purple.opacity(0.5), radius: 12, y: 4)
            }
            .disabled(viewModel.isLoading || viewModel.promptText.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal)
            .animation(.spring(), value: viewModel.isLoading)

            Spacer()
        }
    }
}

// MARK: - Story Page View

struct StoryPageView: View {
    @ObservedObject var viewModel: StoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Page counter
            if let page = viewModel.currentPage {
                Text("Page \(viewModel.currentIndex + 1)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 20) {
                        // Image placeholder / loaded image
                        StoryImageView(imageURL: page.imageURL, imagePrompt: page.imagePrompt)
                            .padding(.horizontal)
                            .padding(.top, 12)

                        // Story sentence
                        StorySentenceView(sentence: page.sentence)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
                .animation(.easeInOut, value: viewModel.currentIndex)
            } else if viewModel.isLoading {
                Spacer()
                LoadingView()
                Spacer()
            }

            Divider()
                .background(.white.opacity(0.1))

            // Navigation controls
            NavigationControlsView(viewModel: viewModel)
                .padding()
        }
    }
}

// MARK: - Story Image View

struct StoryImageView: View {
    let imageURL: String?
    let imagePrompt: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "2a1a4e"), Color(hex: "1a2a4e")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )

            if let _ = imageURL {
                // 🔁 Replace this with your actual image loading:
                // AsyncImage(url: URL(string: imageURL)) { ... }
                // or Image(uiImage: yourUIImage)
                Text("🖼 Image would appear here")
                    .foregroundStyle(.white.opacity(0.5))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.artframe")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("Illustrating scene…")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                    Text(imagePrompt)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.25))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
        }
        .frame(height: 240)
    }
}

// MARK: - Story Sentence View

struct StorySentenceView: View {
    let sentence: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim:"")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundStyle(Color(hex: "7b2fff").opacity(0.7))
                    .offset(x: -4, y: -8)

                Text(sentence)
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(7)
                    .padding(.top, -16)
            }
            .padding(20)
        }
    }
}

// MARK: - Navigation Controls View

struct NavigationControlsView: View {
    @ObservedObject var viewModel: StoryViewModel

    var body: some View {
        HStack(spacing: 16) {
            // Back button
            Button {
                withAnimation(.spring(response: 0.4)) {
                    viewModel.goBack()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.white.opacity(viewModel.canGoBack ? 0.1 : 0.04))
                .foregroundStyle(.white.opacity(viewModel.canGoBack ? 0.9 : 0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
            }
            .disabled(!viewModel.canGoBack)

            // Forward / Continue button
            Button {
                Task {
                    await viewModel.goForward()
                }
            } label: {
                HStack(spacing: 6) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                    } else {
                        Text(viewModel.currentIndex < viewModel.pages.count - 1 ? "Next" : "Continue")
                            .fontWeight(.semibold)
                        Image(systemName: viewModel.currentIndex < viewModel.pages.count - 1 ? "chevron.right" : "wand.and.stars")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(colors: [Color(hex: "7b2fff"), Color(hex: "3b82f6")],
                                   startPoint: .leading, endPoint: .trailing)
                        .opacity(viewModel.isLoading ? 0.5 : 1)
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .purple.opacity(0.4), radius: 8, y: 3)
            }
            .disabled(viewModel.isLoading)
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(.purple)
            Text("Weaving your story…")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Color Hex Helper

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8)  & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

#Preview {
    StoryGeneratorView()
}
