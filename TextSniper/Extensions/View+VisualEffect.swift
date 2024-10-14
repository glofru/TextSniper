//
//  View+VisualEffect.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-10-12.
//

import SwiftUI

extension View {
    func visualEffect() -> some View {
        modifier(VisualEffect())
    }
}

private struct VisualEffect: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            VisualEffectView()

            content
        }
    }
}

private struct VisualEffectView: NSViewRepresentable {
    let visualEffectView = NSVisualEffectView()

    var material: NSVisualEffectView.Material = .popover
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    func makeNSView(context _: Context) -> NSVisualEffectView {
        visualEffectView
    }

    func updateNSView(_: NSVisualEffectView, context _: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
