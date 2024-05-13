//
//  Notifier.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-05-08.
//

import BezelNotification
import AppKit

enum NotificationStatus: String {
    case success = "success"
    case fail = "fail"
}

class Notifier {
    static func show(text: String, status: NotificationStatus) {
        BezelNotification.show(messageText: text, icon: NSImage(named: status.rawValue), fadeOutAnimationDuration: 1)
    }
}
