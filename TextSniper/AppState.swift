//
//  AppState.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-10-12.
//

import Foundation

@Observable
final class AppState: @unchecked Sendable {
    static let shared = AppState()
    
    var appDelegate: AppDelegate?
}
