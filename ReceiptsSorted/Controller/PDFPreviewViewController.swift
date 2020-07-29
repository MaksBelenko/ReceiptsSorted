//
//  PDFPreviewViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 07/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import PDFKit
import SimplePDFBuilder

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
    
    // MARK: - Deinit
    deinit {
        #if DEBUG
            print("DEBUG: PDFPreviewViewController deinit")
        #endif
    }

    
    // MARK: - Initialisation
    init() {
        super.init(nibName: "PDFPreviewViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    
    
    
    // MARK: - PDF Creation
    
    private func createPDFPreviewDocument() {
        let pdfData = createPDF()
        pdfView.document = PDFDocument(data: pdfData)
//        pdfView.interpolationQuality = .low // for images
    }
    
    private func createPDF() -> Data {
        let pdf = PDFBuilder()
        pdf.withMetaTitle("Receipts")
        pdf.withMetaAuthor("WorkReceipts")
        pdf.withMetaCreator("WorkReceipts")
        
        pdf.addFooter(pagingEnabled: true, text: "", colour: .wetAsphalt)
        
        pdf.addImage(image: #imageLiteral(resourceName: "app-noBG-tight"), maxWidth: 60, alignment: .right)
        pdf.addSpace(inches: -0.6)
        pdf.addText(text: "Date: \(dateToday)", alignment: .left, font: .arial(ofSize: 17))
        
        pdf.addSpace(inches: 0.5)
        
        // ----- Table creation -----
        let headers = [PDFColumnHeader(name: "DATE", alignment: .left, weight: 1),
                       PDFColumnHeader(name: "PLACE", alignment: .left, weight: 3),
                       PDFColumnHeader(name: "PRICE", alignment: .right, weight: 1)]
        
        var rows: [PDFTableRow] = []
        for p in passedPayments {
            rows.append(PDFTableRow([p.date?.toString(as: .long) ?? "",
                                     p.place ?? "",
                                     "£\(p.amountPaid.ToString(decimals: 2))"]))
        }
        
        do {
            try pdf.addTable(headers: headers,
                             rows: rows,
                             tableStyle: .Modern,
                             font: .systemFont(ofSize: 11),
                             tableColour: .wetAsphalt)
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
            
            pdf.addImage(image: photo, maxWidth: 200, alignment: .centre)
        }
        
        
        return pdf.build()
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
