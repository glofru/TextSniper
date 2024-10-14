//
//  TextSniperApp.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: FloatingPanel<FloatingPanelContentView>!

    @MainActor let textSnipeManager = TextSnipeManager()

    func applicationWillFinishLaunching(_: Notification) {
        AppState.shared.appDelegate = self
    }

    func applicationDidFinishLaunching(_: Notification) {
        panel = FloatingPanel(
            contentRect: NSRect(origin: .zero, size: .init(width: 100, height: 200)),
            identifier: Bundle.main.bundleIdentifier ?? "org.p0deje.Maccy"
        ) {
            FloatingPanelContentView(textSnipeManager: textSnipeManager)
        }
    }

    func applicationDidResignActive(_: Notification) {
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
