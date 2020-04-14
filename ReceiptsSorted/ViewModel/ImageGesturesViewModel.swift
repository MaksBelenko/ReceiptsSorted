//
//  ImageGestures.swift
//  ReceiptsSorted
//
//  Created by Maksim on 14/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class ImageGesturesViewModel: NSObject {
    
    ///Image's origin to be used for pan gesture
    var imageOrigin : CGPoint!
    
    
    
    
    
    //MARK: - Creation of gestures
    
    /**
     Creates pinch gesture
     */
    func createPinchGesture() -> UIPinchGestureRecognizer {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(ImageGesturesViewModel.pinchGesture))
        pinchGesture.delegate = self
        
        return pinchGesture
    }
    
    /**
     Creates pan gesture with 2 minimum touches
     */
    func createPanGesture() -> UIPanGestureRecognizer {
        let panGestureRecogniser = UIPanGestureRecognizer (target: self, action: #selector(ImageGesturesViewModel.panGesture))
        panGestureRecogniser.delegate = self
        panGestureRecogniser.minimumNumberOfTouches = 2
        
        return panGestureRecogniser
    }
    
    
    
    //MARK: - Pinch & Pan
    
    /**
     Move image gesture
     - Parameter recogniser: Pinch gesture recogniser
     */
    @objc private func panGesture(_ recogniser : UIPanGestureRecognizer) {
        
        guard recogniser.view != nil else { return }
        
        if (recogniser.state == .began) {
            imageOrigin = recogniser.view!.center
        }
        
        if (recogniser.state == .changed) {
            let translation = recogniser.translation(in: recogniser.view)
            recogniser.view!.center = CGPoint(x: recogniser.view!.center.x + translation.x, y: recogniser.view!.center.y + translation.y)
            recogniser.setTranslation(CGPoint.zero, in: recogniser.view!.superview)
        }
        
        if (recogniser.state == .ended || recogniser.state == .failed || recogniser.state == .cancelled) {
            guard let center = imageOrigin else {return}
            UIView.animate(withDuration: 0.3, animations: {
                recogniser.view!.center = center
            }, completion: nil)
        }
        
    }
    
    
    
    
    /**
     Pinch zoom to a specific area
     - Parameter recogniser: Pinch gesture recogniser
     */
    @objc private func pinchGesture(_ recogniser : UIPinchGestureRecognizer) {
        
        guard let recogniserView = recogniser.view else {return}
        
        if (recogniser.state == .began) {
        }
        
        if (recogniser.state == .changed){
            let pinchCenter = CGPoint(x: recogniser.location(in: recogniserView).x - recogniserView.bounds.midX,y: recogniser.location(in: recogniserView).y - recogniserView.bounds.midY)
            let newTransform = recogniserView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y).scaledBy(x: recogniser.scale, y: recogniser.scale).translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            let currentScale = recogniserView.frame.size.width / recogniserView.bounds.size.width
            let newScale = currentScale * recogniser.scale
            recogniserView.transform = (newScale < 1) ? CGAffineTransform.identity : newTransform
            recogniser.scale = 1
        }

        if (recogniser.state == .ended || recogniser.state == .failed || recogniser.state == .cancelled) {
            UIView.animate(withDuration: 0.3, animations: {
                recogniserView.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    
}



//MARK: - UIGestureRecognizerDelegate extension
extension ImageGesturesViewModel: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
