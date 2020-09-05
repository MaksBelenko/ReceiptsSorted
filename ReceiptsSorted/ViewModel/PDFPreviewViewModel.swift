//
//  PDFPreviewViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 05/09/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Foundation
import PDFKit
import SimplePDFBuilder

class PDFPreviewViewModel {
    
    private(set) var pdfData: Data?
    
    private var pdfFileName: String = {
        let dateToday = Date().toString(as: .medium)
        let fileName = "Receipts \(dateToday).pdf"
        return fileName
    }()
    
    // MARK: - Public methods
    
    func createPDFPreviewDocument(for payments: [Payment]) -> PDFDocument? {
        pdfData = createPDF(for: payments)
        return PDFDocument(data: pdfData!)
    }
    
    func savePdfToFile() throws -> URL {
        let temporaryFileURL = createTempFileURL(for: pdfFileName)
        try pdfData?.write(to: temporaryFileURL)
        return temporaryFileURL
    }
    
    
    // MARK: - Private methods
    
    private func createTempFileURL(for fileName: String) -> URL {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        Log.debug(message: "Files are saved to: \(temporaryFileURL.path)")
        
        return temporaryFileURL
    }
    
    
    private func createPDF(for passedPayments: [Payment]) -> Data {
        let pdfColour = UIColor.flatBlue
        
        let pdf = PDFBuilder()
        pdf.withMetaTitle("Receipts")
        pdf.withMetaAuthor("WorkReceipts")
        pdf.withMetaCreator("WorkReceipts")
        
        pdf.addFooter(pagingEnabled: true, text: "", colour: pdfColour)
        
        pdf.addImage(image: #imageLiteral(resourceName: "app-noBG-tight"), maxWidth: 60, alignment: .right)
        pdf.addSpace(inches: -0.6)
        
        let dateFormatterHelper = DateFormatterHelper()
        let formattedDateToday = dateFormatterHelper.getDashFomattedDate(from: Date())
        pdf.addText(text: "Date: \(formattedDateToday)", alignment: .left, font: .arial(ofSize: 17))
        
        pdf.addSpace(inches: 0.5)
        
        // ----- Table creation -----
        let headers = [PDFColumnHeader(name: "DATE", alignment: .left, weight: 1),
                       PDFColumnHeader(name: "PLACE", alignment: .left, weight: 3),
                       PDFColumnHeader(name: "PRICE", alignment: .right, weight: 1)]
        
        var rows: [PDFTableRow] = []
        for p in passedPayments {
            rows.append(PDFTableRow([p.date?.toString(as: .medium) ?? "",
                                     p.place ?? "",
                                     "\(p.currencySymbol!)\(p.amountPaid.ToString(decimals: 2))"]))
        }
        
        do {
            try pdf.addTable(headers: headers,
                             rows: rows,
                             tableStyle: .Modern,
                             font: .systemFont(ofSize: 11),
                             tableColour: pdfColour)
        } catch {
            Log.exception(message: "Error creating PDF table, Error: \(error.localizedDescription)")
        }
        
        
        // ----- Add images -----
        for p in passedPayments {
            pdf.newPage()
            guard let rp = p.receiptPhoto,
                let imageData = rp.imageData,
                let photo = UIImage(data: imageData) else
            {
                pdf.addText(text: "Couldn't retrieve image for \(p.place ?? "")",
                    alignment: .centre, font: .arial(ofSize: 20), colour: .black)
                continue
            }
            
            pdf.addImage(image: photo, maxWidth: 300, alignment: .centre)
        }
        
        
        return pdf.build()
    }
}
