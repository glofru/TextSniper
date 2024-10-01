//
//  TextSnipe.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import Foundation

@MainActor class TextSnipeManager: ObservableObject {
    
    @Published var textSnipe: TextSnipe?
    
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
}
