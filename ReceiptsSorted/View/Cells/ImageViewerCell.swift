//
//  ImageViewerCell.swift
//  ReceiptsSorted
//
//  Created by Maksim on 14/05/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class ImageViewerCell: UICollectionViewCell {
    
    private var imageGestures = ImageGestures()
    
    weak var picture: UIImage? {
        didSet {
            guard let picture = picture else { return }
            imageView.image = picture
        }
    }
    
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .clear
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.cornerRadius = 0
        image.isUserInteractionEnabled = true
        return image
    }()
    
    
    deinit {
        print("DEBUG: ImageViewerCell deinit")
    }
    
    // MARK: - Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.addGestureRecognizer(imageGestures.createPinchGesture()) //Pinch Gesture
        imageView.addGestureRecognizer(imageGestures.createPanGesture()) //Pan Gesture
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
