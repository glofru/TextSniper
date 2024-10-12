//
//  TextSniperApp.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: FloatingPanel<TextSniperFloatingPanel>!
    
    @MainActor let textSnipeManager = TextSnipeManager()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        AppState.shared.appDelegate = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Finish launching")
        panel = FloatingPanel(
            contentRect: NSRect(origin: .zero, size: .init(width: 100, height: 200)),
          identifier: Bundle.main.bundleIdentifier ?? "org.p0deje.Maccy"
        ) {
            TextSniperFloatingPanel(textSnipeManager: textSnipeManager)
        }
    }

    func applicationDidResignActive(_ notification: Notification) {
        panel.close()
    }
}

@main
struct TextSniperApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @ObservedObject private var textSnipeManager: TextSnipeManager
    
    init() {
        textSnipeManager = _delegate.wrappedValue.textSnipeManager
    }

    var body: some Scene {
        TextSniperMenuBar()
            .environmentObject(textSnipeManager)
    }
}
