//
//  TextSniperMenuBar.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import SwiftUI

import HotKey

struct TextSniperMenuBar: Scene {
    
    @StateObject var textSnipeManager = TextSnipeManager()
    
    private var newScreentshotHotKey = HotKey(key: .init(string: "2")!, modifiers: [.command, .shift])
    
    var body: some Scene {
        MenuBarExtra {
            Text("Text Sniper")
            
            Divider()
            
            Button("Snipe screenshot", action: snipeScreenshot)
                .keyboardShortcut(KeyEquivalent("2"), modifiers: [.command, .shift])
            Button("Quit", action: quitApp)
        } label: {
            Image(systemName: "bolt.fill")
                .onAppear {
                    newScreentshotHotKey.keyDownHandler = snipeScreenshot
                }
        }
    }
    
    private func snipeScreenshot() {
        Task {
            if let _ = await textSnipeManager.snipeScreenshot() {
                Notifier.show(text: "Copied to clipboard", status: .success)
            } else {
                Notifier.show(text: "Failed to copy to clipboard", status: .fail)
            }
        }
    }
    
    private func quitApp() {
        NSApp.terminate(nil)
    }
}
