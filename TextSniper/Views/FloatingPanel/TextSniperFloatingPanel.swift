//
//  TextSniperFloatingPanel.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-29.
//

import SwiftUI

struct TextSniperFloatingPanel: View {
    
    @ObservedObject var textSnipeManager: TextSnipeManager

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
                        
                    }
                    
                    ButtonWithIcon(icon: "qrcode.viewfinder", label: "Read QR Code") {
                        
                    }
                    
                    ButtonWithIcon(icon: "square.and.arrow.down", label: "Save") {
                        
                    }
                }
            }
            .frame(width: 800)
            .padding()
            .edgesIgnoringSafeArea(.all)
            .onAppear {
//                textSnipeManager.textSnipe = TextSnipe(image: NSImage(named: "test")!.cgImage(forProposedRect: nil, context: nil, hints: nil)!, chunks: [])
            }
        }
    }
}

#Preview {
    let manager = TextSnipeManager()
    
    return TextSniperFloatingPanel(textSnipeManager: TextSnipeManager())
}
