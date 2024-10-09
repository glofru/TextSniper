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
                            guard let client = AWSClient() else {
                                print("Failed client")
                                return
                            }

                            await client.initModels()
                            print(client.modelIds)
                            do {
                                let stream = try await client.summarize(text: "Summarize the following text.\n\n\(textSnipeManager.textSnipe!.chunks.joined(separator: "\n"))")
                                
                                streamedText = ""
                                for try await event in stream {
                                    switch event {
                                    case .chunk(let part):
                                        let jsonObject = try JSONSerialization.jsonObject(with: part.bytes!, options: [])
                                        if let chunkText = extractTextFromChunk(jsonObject) {
                                            DispatchQueue.main.async {
                                                streamedText! += chunkText
                                            }
                                        }
                                    case .sdkUnknown(let unknown):
                                        print("Unknown: \"\(unknown)\"")
                                    }
                                }
                            } catch {
                                print("Error summary \(error)")
                            }
                        }
                    }
                    
                    ButtonWithIcon(icon: "list.bullet.rectangle.portrait", label: "Ask with custom input") {
                        
                    }
                    
                    ButtonWithIcon(icon: "qrcode.viewfinder", label: "Read QR Code") {
                        
                    }
                    
                    ButtonWithIcon(icon: "square.and.arrow.down", label: "Save") {
                        
                    }
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
    }
    
    private func extractTextFromChunk(_ jsonObject: Any) -> String? {
        if let dict = jsonObject as? [String: Any], let delta = dict["delta"] as? [String: String], delta["type"] == "text_delta" {
            return delta["text"]
        }
        return nil
    }
}

#Preview {
    return TextSniperFloatingPanel(textSnipeManager: TextSnipeManager())
}
