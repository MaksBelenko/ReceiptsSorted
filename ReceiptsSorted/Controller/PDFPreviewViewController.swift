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
    private let viewModel = PDFPreviewViewModel()
    
    
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
        
        pdfView.document = viewModel.createPDFPreviewDocument(for: passedPayments)
    }

    
    
    // MARK: - Configuring UI
    private func setupNavigationBar() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.navigationColour
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
        pdfView.backgroundColor = .whiteGrayDynColour
        
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
    
    
    
    // MARK: - IBActions
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        Alert.shared.showDismissPdfAlert(for: self)
    }
       
    
    @IBAction func sendEmailButtonPressed(_ sender: UIBarButtonItem) {
        do {
            let pdfFileURL = try viewModel.savePdfToFile()
            let activityViewController = UIActivityViewController(activityItems: [pdfFileURL], applicationActivities: nil)
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
