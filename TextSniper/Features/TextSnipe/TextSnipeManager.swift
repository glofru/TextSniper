//
//  TextSnipeManager.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import Foundation

@MainActor class TextSnipeManager: ObservableObject {
    private var client: TextSniperClient {
        get async throws {
            try await TextSniperClient()
        }
    }

    @Published var textSnipe: TextSnipe?
    @Published var streaming: Bool = false
    @Published var streamedText: String?
    @Published var error: String?

    func snipeScreenshot() async {
        guard let screenshot = ScreenshotTool.takeScreenshot() else {
            textSnipe = nil
            return
        }

        let text = await TextRecognizer.readText(from: screenshot)

        let copyResult = ClipboardManager.copyText(text.joined(separator: "\n"))

        textSnipe = switch copyResult {
        case .success(()): TextSnipe(image: screenshot, chunks: text)
        default: nil
        }
    }

    func summarizeTextSnipe() {
        guard let textSnipe else {
            return
        }

        Task {
            do {
                let client = try await TextSniperClient()
                let stream = await client.summarize(text: textSnipe.chunks.joined(separator: "\n"))

                streaming = true

                streamedText = ""
                for try await event in stream {
                    streamedText! += event.text
                }
            } catch {
                self.error = error.localizedDescription
            }

            streaming = false
        }
    }
}
