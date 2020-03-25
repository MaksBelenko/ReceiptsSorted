//
//  TextRecogniser.swift
//  ReceiptsSorted
//
//  Created by Maksim on 15/01/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import Vision

class TextRecogniserViewModel {
    
    var textFound: String = ""
    var priceFound: Float!
    
    func findReceiptDetails (for passedImage: UIImage) -> Float {
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        request.recognitionLevel = .accurate
        //request.recognitionLanguages = ["en_GB"]
        request.customWords = ["£"]
        
        let requests = [request]

        //DispatchQueue.global(qos: .userInitiated).async {
            
        guard let img = passedImage.cgImage else {
            fatalError("Missing image to scan")
        }

        let handler = VNImageRequestHandler(cgImage: img, options: [:])
        try? handler.perform(requests)
        //}
        
        return priceFound
    }
        
        
        
    private func handleDetectedText(request: VNRequest?, error: Error?) {
        if let error = error {
            print("ERROR: \(error)")
            return
        }
        guard let results = request?.results, results.count > 0 else {
            print("No text found")
            return
        }

        var allWords: [String] = []
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    print(text.string)
                    print(text.confidence)
                    print(observation.boundingBox)
                    print("\n")
                    
                    allWords.append(text.string)
                }
            }
        }
        
        for word in allWords {
            if word.hasPrefix("£") {
                print("FOUND: \(word) ")
                priceFound = word.components(separatedBy: "£")[1].floatValue
            }
        }
    }
    
}

