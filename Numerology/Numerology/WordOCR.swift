//
//  WordOCR.swift
//  Numerology
//
//  Vision OCR for a cropped camera reticle region.
//

import Foundation
import UIKit
import Vision

enum WordOCR {
    /// Recognize text in an image; prefers the strongest alphanumeric token.
    static func recognizePrimaryWord(in image: UIImage) async -> String? {
        let candidates = await recognizeStrings(in: image)
        return pickBestToken(from: candidates)
    }
    
    static func recognizeStrings(in image: UIImage) async -> [String] {
        guard let cgImage = image.cgImage else { return [] }
        
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
                let strings = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: strings)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.recognitionLanguages = ["en-US"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }
    
    /// Prefer longest alphanumeric token (letters + digits), then longest overall.
    static func pickBestToken(from strings: [String]) -> String? {
        let tokens = strings
            .flatMap { $0.split { !$0.isLetter && !$0.isNumber }.map(String.init) }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if let best = tokens.max(by: { $0.count < $1.count }) {
            return best
        }
        
        let joined = strings
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return joined.max(by: { $0.count < $1.count })
    }
}
