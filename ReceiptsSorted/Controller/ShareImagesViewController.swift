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

    var passedPayments: [Payment] = []
    private var paymentsCount: Int = 1
    private var viewModel: ShareImagesViewModel!

    
    // MARK: - Computed properties
    
    private var imageCount: Int = 0 {
        didSet {
            imageCountLabel.text = "\(imageCount)/\(paymentsCount)"
        }
    }
    
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
        cv.backgroundColor = .clear
        return cv
    }()
    
    private let imageCountLabel: UILabel = {
        let label = UILabel()
        label.text = "1/0"
        label.font = UIFont.arial(ofSize: 16)
        label.tintColor = .black
        return label
    }()

    
    
    // MARK: - Deinit
    deinit {
        #if DEBUG
            let navStatus = (self.navigationController == nil)
            print("DEBUG: ShareImagesViewController deinit, navController status is nil? \(navStatus)")
        #endif
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Images Viewer"
        view.backgroundColor = .whiteGrayDynColour
        
        viewModel = ShareImagesViewModel(payments: passedPayments)
        viewModel.startPhotosZipOperations()
        
        setupNavigationBar()
        setupBarButtons()
        
        setupCollectionView()
        setupCountLabel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.cancelAllOperations()
    }

    
    // MARK: - Configure UI
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.navigationColour
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
    
    
    private func setupCountLabel() {
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
        Alert.shared.showShareSelector(for: self, onShareClicked: showActivityVC(for:))
    }
    
    func showActivityVC(for shareType: ShareImagesType) {
        guard let activityVC = viewModel.createActivityVC(for: shareType) else { return }
        present(activityVC, animated: true, completion: nil)
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
        cell.picture = receiptImage.roundCorners(proportion: 20)
        
        return cell
    }
}
