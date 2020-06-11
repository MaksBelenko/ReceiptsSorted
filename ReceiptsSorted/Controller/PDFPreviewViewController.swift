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
    
    var passedPayments: [Payment]!
    
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

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationController?.delegate = self
        
        setupNavigationBar()
        setupPDFView()
        createPDFPreviewDocument()
    }

    
    
    // MARK: - Configuring UI
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
    
    
    
    
    // MARK: - Helpers
    
    private func createPDFPreviewDocument() {
        let pdfCreator = PdfFactory(payments: passedPayments)
        pdfData = pdfCreator.createPDF()
        pdfView.document = PDFDocument(data: pdfData)
//        pdfView.interpolationQuality = .low // for images
    }
    
    
    
    
    
    // MARK: - IBActions
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        Alert.shared.showDismissPdfAlert(for: self)
    }
       
    
    @IBAction func sendEmailButtonPressed(_ sender: UIBarButtonItem) {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = "Receipts \(dateToday).pdf"
        
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        Log.debug(message: "Files are saved to: \(temporaryFileURL.path)")


        do {
            try pdfData!.write(to: temporaryFileURL) //Write document to defaults storage

            let activityViewController = UIActivityViewController(activityItems: [temporaryFileURL], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } catch {
            print(error)
        }
    }
    
}



// MARK: - UIAdaptivePresentationControllerDelegate
extension PDFPreviewViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        Alert.shared.showDismissPdfAlert(for: self)
    }
}
