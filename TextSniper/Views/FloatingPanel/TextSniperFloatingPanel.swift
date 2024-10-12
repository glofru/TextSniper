//
//  TextSniperFloatingPanel.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-29.
//

import SwiftUI

struct TextSniperFloatingPanel: View {
    @ObservedObject var textSnipeManager: TextSnipeManager

    @State private var streamedText: String?

    @State private var error: Error?

    var body: some View {
        ZStack {
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
                        Task {
                            do {
                                let client = try await TextSniperClient()
                                let stream = await client.summarize(text: textSnipeManager.textSnipe!.chunks.joined(separator: "\n"))

                                streamedText = ""
                                for try await event in stream {
                                    streamedText! += event.text
                                }
                            } catch {
                                self.error = error
                            }
                        }
                    }

                    ButtonWithIcon(icon: "list.bullet.rectangle.portrait", label: "Ask with custom input") {}

                    ButtonWithIcon(icon: "qrcode.viewfinder", label: "Read QR Code") {}

                    ButtonWithIcon(icon: "square.and.arrow.down", label: "Save") {}
                }
                .disabled(textSnipeManager.textSnipe == nil)
            }
            .frame(width: 800)
            .padding()
            .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: .init(get: {
            streamedText != nil
        }, set: { _ in
            streamedText = nil
        })) {
            Text(streamedText!)
                .textSelection(.enabled)
                .padding()
        }
        .alert(isPresented: .init(get: {
            error != nil
        }, set: { _ in
            error = nil
        })) {
            Alert(title: Text("Error"), message: Text(error!.localizedDescription))
        }
    }
}

#Preview {
    TextSniperFloatingPanel(textSnipeManager: TextSnipeManager())
}
