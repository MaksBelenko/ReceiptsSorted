//
//  PDFPreviewViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import PDFKit

class PDFPreviewViewController: UIViewController {
    
    var passedPayments: [Payments]!
    
    @IBOutlet weak var topNavigationBar: UINavigationBar!
    @IBOutlet weak var previewView: UIView!
    private let pdfView = PDFView()
    private var pdfData: Data!
    private let buttonAnimations = AddButtonAnimations()

    var dateToday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: Date())
    }

    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupPDFView()
        createPDFPreviewDocument()
    }

    
    
    private func setupNavigationBar() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.wetAsphalt
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            topNavigationBar.standardAppearance = appearance
            topNavigationBar.scrollEdgeAppearance = appearance
            topNavigationBar.compactAppearance = appearance // For iPhone small navigation bar in landscape.
        } else {
            topNavigationBar.barTintColor = UIColor.wetAsphalt
            topNavigationBar.tintColor = UIColor.white
            topNavigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
    
    
    
    private func setupPDFView() {
        pdfView.backgroundColor = .white
        
        previewView.addSubview(pdfView)

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.topAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor).isActive = true
        pdfView.leftAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.leftAnchor).isActive = true
        pdfView.rightAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displaysPageBreaks = true
//        pdfView.goToFirstPage()
    }
    
    
    private func createPDFPreviewDocument() {
        let pdfCreator = PDFCreator(payments: passedPayments)
        pdfData = pdfCreator.createPDF()
        pdfView.document = PDFDocument(data: pdfData)
    }
    
    
    
    
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
       
    
    @IBAction func sendEmailButtonPressed(_ sender: UIBarButtonItem) {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = "Receipts \(dateToday).pdf"
        
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        LogHelper.debug(message: "Files are saved to: \(temporaryFileURL.path)")
        
//        do {
//            let temporaryFileURL = temporaryFolder.appendingPathComponent("test.zlib")
//            let compressedData = try (pdfData as NSData).compressed(using: .zlib)
//            try compressedData.write(to: temporaryFileURL)
//        } catch {
//            LogHelper.exception(message: "Error with compressed data: Error = \(error.localizedDescription)")
//        }
        
        do {
            try pdfData!.write(to: temporaryFileURL) //Write document to defaults storage
            
            let activityViewController = UIActivityViewController(activityItems: [temporaryFileURL], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } catch {
            print(error)
        }
    }
    
}
