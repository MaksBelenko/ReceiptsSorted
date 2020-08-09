//
//  WorldCurrencies.swift
//  ReceiptsSorted
//
//  Created by Maksim on 12/07/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation

///Gets currencies from JSON file
class WorldCurrencies {
    ///Array of currencies
    private(set) var currencies: [Currency] = []
    
    
    // MARK: - Initialisation
    init() {
        let jsonData = readLocalFile(forName: "Common-Currency")
        currencies = parse(jsonData: jsonData!).sorted{ $0.name < $1.name }
    }
    
    
    // MARK: - Private methods
    
    /**
     Get data from JSON file
     */
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    
    /**
     Decode data into [Currency] array
     */
    private func parse(jsonData: Data) -> [Currency] {
        do {
            return try JSONDecoder().decode([Currency].self, from: jsonData)
        } catch {
            print(error)
            return []
        }
    }
}
