//
//  TextSniperApp.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-05-07.
//

import HotKey
import SwiftUI
import Vision

let destinationPath = "screen.png"

@main
struct TextSniperApp: App {
    
    var newScreentshotHotKey = HotKey(key: .init(string: "6")!, modifiers: [.command, .shift])

    var body: some Scene {
        MenuBarExtra {
            Text("Hello Status Bar Menu!")
            Divider()
            Button("New Screenshot", action: newScreenshot)
            .keyboardShortcut(KeyEquivalent("6"), modifiers: [.command, .shift])
            Button("Quit") { NSApp.terminate(nil) }
        } label: {
            Image(systemName: "bolt.fill")
                .onAppear {
                    newScreentshotHotKey.keyDownHandler = newScreenshot
                }
        }
    }
    
    private func newScreenshot() {
        if let image = takeScreenshot() {
            readText(image)
        }
    }
    
    private func takeScreenshot() -> CGImage? {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r", destinationPath]
        task.launch()
        task.waitUntilExit()
        
        guard task.terminationStatus == 0 else {
            return nil
        }
        
        let image = NSImage(contentsOfFile: destinationPath)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        
        try? FileManager.default.removeItem(atPath: destinationPath)
        
        return image
    }
    
    private func readText(_ image: CGImage) {
        let requestHandler = VNImageRequestHandler(cgImage: image)
        let recognizeTextRequest = VNRecognizeTextRequest(completionHandler: { request, error in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            
            copyTextToClipboard(recognizedStrings)
        })
        
        do {
            try requestHandler.perform([recognizeTextRequest])
        } catch {
            Notifier.show(text: "Failed to perform the text extraction request", status: .fail)
        }
    }
    
    private func copyTextToClipboard(_ texts: [String]) {
        let text = texts.joined(separator: "\n")
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.setString(text, forType: .string)
        
        if success {
            Notifier.show(text: "Copied to clipboard", status: .success)
        } else {
            Notifier.show(text: "Failed to copy to clipboard", status: .fail)
        }
    }
    
    private func showNotification(text: String) {
        
    }
}
