//
//  String+Identifiable.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-10-14.
//

import SwiftUI

extension String: @retroactive Identifiable {
    public var id: Self {
        self
    }
}
