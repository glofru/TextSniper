//
//  FloatingPanelContentView.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-29.
//

import SwiftUI

struct FloatingPanelContentView: View {
    @ObservedObject var textSnipeManager: TextSnipeManager

    var body: some View {
        VStack {
            if let textSnipe = textSnipeManager.textSnipe {
                Image(decorative: textSnipe.image, scale: 1)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .frame(maxHeight: 300)
            } else {
                Text("No screenshot available.")
                    .frame(height: 300)
                    .frame(maxHeight: 300)
            }

            HStack {
                ButtonWithIcon(icon: "list.bullet.rectangle.portrait", label: "Summarize text") {
                    textSnipeManager.summarizeTextSnipe()
                }

                ButtonWithIcon(icon: "text.page.badge.magnifyingglass", label: "Analyze image") {}

                ButtonWithIcon(icon: "list.bullet.rectangle.portrait", label: "Ask with custom input") {}

                ButtonWithIcon(icon: "qrcode.viewfinder", label: "Read QR Code") {}

                ButtonWithIcon(icon: "square.and.arrow.down", label: "Save") {}
            }
            .disabled(textSnipeManager.textSnipe == nil)
        }
        .frame(width: 800)
        .visualEffect()
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: .init(get: {
            textSnipeManager.streamedText != nil
        }, set: { isPresented in
            if !isPresented {
                textSnipeManager.streamedText = nil
            }
        })) {
            FloatingPanelSheetView(textSnipeManager: textSnipeManager)
        }
        .alert(item: $textSnipeManager.error) { error in
            Alert(title: Text("Error"), message: Text(error))
        }
    }
}

private struct FloatingPanelSheetView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var textSnipeManager: TextSnipeManager

    private var text: String? {
        textSnipeManager.streamedText
    }

    var body: some View {
        VStack {
            Text(text ?? "...")
                .textSelection(.enabled)

            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                }.keyboardShortcut(.cancelAction)

                Button(action: {
                    dismiss(text: text)
                }) {
                    Text("Copy and close")
                }.keyboardShortcut(.defaultAction)
                    .disabled(textSnipeManager.streaming)
            }
        }
        .padding()
    }

    private func dismiss(text: String? = nil) {
        if let text {
            ClipboardManager.copyText(text)
        }

        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    FloatingPanelContentView(textSnipeManager: TextSnipeManager())
}
