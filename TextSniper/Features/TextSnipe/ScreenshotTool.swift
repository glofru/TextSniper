//
//  ScreenshotTool.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import SwiftUI

class ScreenshotTool {
    static func takeScreenshot() -> CGImage? {
        ScreenCapture.captureScreen()
    }
}

fileprivate class ScreenCapture {
    static private let destinationPath = "screen.png"

    static func captureScreen() -> CGImage? {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r", destinationPath]
        task.launch()
        
        task.waitUntilExit()
        
        let image = NSImage(contentsOfFile: destinationPath)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        
        try? FileManager.default.removeItem(atPath: destinationPath)
        
        return image
    }
}
