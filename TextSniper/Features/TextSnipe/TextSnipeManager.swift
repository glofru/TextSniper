//
//  TextSnipe.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import Foundation

actor TextSnipeManager: ObservableObject {
    func snipeScreenshot() async -> TextSnipe? {
        if let screenshot = ScreenshotTool.takeScreenshot() {
            let text = await TextRecognizer.readText(from: screenshot)
            
            let copyResult = await ClipboardManager.copyText(text.joined(separator: "\n"))
            
            return switch copyResult {
            case .success(()): TextSnipe(chunks: text)
            default: nil
            }
        }
        
        return nil
    }
}
