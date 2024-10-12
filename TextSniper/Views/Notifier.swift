//
//  Notifier.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import AppKit
import BezelNotification

enum NotificationStatus: String {
    case success
    case fail
}

class Notifier {
    static func show(text: String, status: NotificationStatus) {
        BezelNotification.show(messageText: text, icon: NSImage(named: status.rawValue), fadeOutAnimationDuration: 1)
    }
}
