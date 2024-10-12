//
//  ClipboardManager.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import SwiftUI

enum ClipboardError: Error {
    case failedToCopy
}

class ClipboardManager {
    @MainActor private static let pasteboard = NSPasteboard.general

    @MainActor static func copyText(_ text: String) -> Result<Void, ClipboardError> {
        pasteboard.clearContents()
        let success = pasteboard.setString(text, forType: .string)

        switch success {
        case true: return .success(())
        default: return .failure(.failedToCopy)
        }
    }
}
