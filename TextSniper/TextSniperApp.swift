//
//  TextSniperApp.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var floatingPanel: FloatingPanel!
    
    @MainActor let textSnipeManager = TextSnipeManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createFloatingPanel()

        // Center doesn't place it in the absolute center, see the documentation for more details
        floatingPanel.center()

        // Shows the panel and makes it active
        floatingPanel.orderFront(nil)
        floatingPanel.makeKey()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        print("Active")
    }

    @MainActor private func createFloatingPanel() {
        // Create the SwiftUI view that provides the window contents.
        // I've opted to ignore top safe area as well, since we're hiding the traffic icons
        let contentView = TextSniperFloatingPanel(textSnipeManager: textSnipeManager)
          .edgesIgnoringSafeArea(.top)

        // Create the window and set the content view.
        floatingPanel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 800, height: 80), backing: .buffered, defer: false)

        floatingPanel.contentView = NSHostingView(rootView: contentView)
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
