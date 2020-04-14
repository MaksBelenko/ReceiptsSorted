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
    @IBOutlet weak var sendEmailButton: UIButton!
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
        setupEmailButton()
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
    
    
    private func setupEmailButton() {
        sendEmailButton.layer.cornerRadius = 13//sendEmailButton.frame.size.height/2
        sendEmailButton.layer.applyShadow(color: .black, alpha: 0.25, x: 5, y: 10, blur: 10)
        buttonAnimations.startAnimatingPressActions(for: sendEmailButton)
    }
    
    
    private func setupPDFView() {
        pdfView.backgroundColor = .white
        pdfView.layer.borderWidth = 1
        pdfView.layer.borderColor = UIColor.flatOrange.cgColor
        
        previewView.addSubview(pdfView)

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.topAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        pdfView.leftAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        pdfView.rightAnchor.constraint(equalTo: previewView.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        
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
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func sendEmailButtonPressed(_ sender: UIButton) {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = "Receipts \(dateToday).pdf"
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        print(temporaryFileURL.path)
        do {
            try pdfData!.write(to: temporaryFileURL) //Write document to defaults storage
            
            let activityViewController = UIActivityViewController(activityItems: [temporaryFileURL], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } catch {
            print(error)
        }
    }
    
}
