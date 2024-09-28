//
//  TextRecognizer.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-28.
//

import Foundation
import CoreGraphics
import Vision

class TextRecognizer {
    static func readText(from image: CGImage) async -> [String] {
        await withCheckedContinuation { continuation in
            VisionTextRecognizer.readText(from: image) { text in
                continuation.resume(returning: text)
            }
        }
    }
}

fileprivate class VisionTextRecognizer {
    static func readText(from image: CGImage, completion: @escaping ([String]) -> Void) {
        let requestHandler = VNImageRequestHandler(cgImage: image)
        let recognizeTextRequest = VNRecognizeTextRequest(completionHandler: { request, error in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                observation.topCandidates(1).first?.string
            }
            
            completion(recognizedStrings)
        })
        
        do {
            try requestHandler.perform([recognizeTextRequest])
        } catch {
            completion([])
        }
    }
}
