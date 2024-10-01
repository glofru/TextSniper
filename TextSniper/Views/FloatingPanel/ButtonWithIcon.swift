//
//  ButtonWithIcon.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-30.
//

import SwiftUI

struct ButtonWithIcon: View {
    
    let icon: String
    let label: String
    let action: @MainActor () -> Void
    
    var body: some View {
        Button(action: action, label: {
            ZStack {
                VStack {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                    Text(label)
                }
            }
        })
        .frame(width: 100, height: 50)
        .padding()
        .background(.gray.opacity(0.15))
        .buttonStyle(.borderless)
        .cornerRadius(16)
    }
}

#Preview {
    ButtonWithIcon(icon: "qrcode.viewfinder", label: "Scan QR Code", action: {})
}
