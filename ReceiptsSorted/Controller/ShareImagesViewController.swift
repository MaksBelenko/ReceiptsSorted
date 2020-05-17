//
//  ArchiveImagesViewController.swift
//  ReceiptsSorted
//
//  Created by Maksim on 13/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import Zip

private let cellReuseIdentifier = "Cell"

class ShareImagesViewController: UIViewController {

    var passedPayments: [Payments]!
    private var paymentsCount: Int = 1
    
    private var imageCount: Int = 0 {
        didSet {
            imageCountLabel.text = "\(imageCount)/\(paymentsCount)"
        }
    }
    
    private let directoryName = "Receipts"
    private var zipURL: URL!
    var photosURLs = [URL]()
    
    private lazy var cancelBarButton: UIBarButtonItem = {
        guard let closeImage = UIImage(systemName: "xmark") else { return UIBarButtonItem() }
        return UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(cancelButtonPressed))
    }()

    private lazy var shareBarButton: UIBarButtonItem = {
        guard let shareImage = UIImage(systemName: "square.and.arrow.up") else { return UIBarButtonItem() }
        return UIBarButtonItem(image: shareImage, style: .plain, target: self, action: #selector(shareButtonPressed))
    }()
    
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.decelerationRate = .fast
        cv.contentInsetAdjustmentBehavior = .always
        cv.showsHorizontalScrollIndicator = false
        cv.register(ImageViewerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        return cv
    }()
    
    private let imageCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1/0"
        label.font = UIFont(name: "Arial", size: 16)!
        label.tintColor = .black
        return label
    }()

    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Images Viewer"
        view.backgroundColor = .white
        setupNavigationBar()
        setupBarButtons()
        
        setupCollectionView()
        setupLCountLabel()
        
        DispatchQueue.global(qos: .utility).async {
            let directoryPath = self.createDirectory()
            self.addPhotosToDirectory(withPath: directoryPath)
            self.zipURL = self.zipDirectory(withPath: directoryPath)
        }
    }

    
    // MARK: - Configure UI
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.wetAsphalt
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance // For iPhone small navigation bar in landscape.
        } else {
            navigationController?.navigationBar.barTintColor = UIColor.wetAsphalt
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
    
    
    private func setupBarButtons() {
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = shareBarButton
    }
    
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75).isActive = true
        view.layoutIfNeeded()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = CollectionViewFlowLayout(size: CGSize(width: collectionView.frame.width/2,
                                                                                    height: collectionView.frame.height * 0.7))
    }
    
    
    private func setupLCountLabel() {
        paymentsCount = passedPayments.count
        imageCountLabel.text = "1/\(paymentsCount)"
        
        view.addSubview(imageCountLabel)
        imageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        imageCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageCountLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -5).isActive = true
    }
    
    
    
    // MARK: - Buttons actions
    
    @objc private func cancelButtonPressed() {
        Alert.shared.showDismissPdfAlert(for: self)
    }
    
    @objc private func shareButtonPressed() {
        Alert.shared.showShareSelector(for: self)
    }
    
    func showActivityVC(for shareType: ShareImagesType) {
        let activityVC: UIActivityViewController
        
        switch shareType {
        case .RawImages:
            activityVC = UIActivityViewController(activityItems: photosURLs, applicationActivities: nil)
        case .Zip:
            guard let url = zipURL else { return }
            activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        }
        
        present(activityVC, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Helpers
    
    private func createDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let directoryURL = docURL.appendingPathComponent(directoryName)
        
        if FileManager.default.fileExists(atPath: directoryURL.absoluteString) {
            do {
                print("Removing directory \(directoryURL.path)")
                try FileManager.default.removeItem(atPath: directoryURL.path)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        // Create the directory again
        do {
            print("Creating directory in \(directoryURL.path)")
            try FileManager.default.createDirectory(atPath: directoryURL.absoluteString, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        
        
        return directoryURL.path
    }
    
    
    private func addPhotosToDirectory(withPath path: String) {
        var namesDictionary = Dictionary<String, Int>()
        
        for payment in passedPayments {
            guard let receiptPhotoData = payment.receiptPhoto else { return }
            guard let placeName = payment.place else { return }
            
            if !namesDictionary.contains(where: {$0.key == placeName} ) {
                namesDictionary[placeName] = 0
            } else {
                namesDictionary[placeName]! += 1
            }
            
            let count = (namesDictionary[placeName] == 0) ? "" : "_\(namesDictionary[placeName]!)"
            let fileName = "\(placeName)\(count).jpg"//"Image\(photoCounter).jpg"
            
            let fileURL = URL(fileURLWithPath: path).appendingPathComponent(fileName)
            photosURLs.append(fileURL)
            
            do {
                guard let imageData = receiptPhotoData.imageData else { fatalError("No ImageDaa to write to directory") }
                try imageData.write(to: fileURL)  // writes the image data to disk
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    
    private func zipDirectory(withPath directoryPath: String) -> URL? {
        do {
            let directoryURL = URL(fileURLWithPath: directoryPath)
            return try Zip.quickZipFiles([directoryURL], fileName: directoryName) // Zip
        } catch {
            print("Zip failed with error: \(error.localizedDescription)")
            return nil
        }
    }
}


// MARK: - UICollectionViewDelegate
extension ShareImagesViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x,
                            y: collectionView.center.y + collectionView.contentOffset.y)
        
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        imageCount = indexPath.row + 1
    }
}


// MARK: - UICollectionViewDataSource
extension ShareImagesViewController: UICollectionViewDataSource  {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passedPayments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ImageViewerCell
        
        guard let imageData = passedPayments[indexPath.row].receiptPhoto?.imageData,
            let receiptImage = UIImage(data: imageData) else { return cell }
        
        cell.picture = receiptImage

        return cell
    }
}
