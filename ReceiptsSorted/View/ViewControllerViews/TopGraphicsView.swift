//
//  TopGraphicsView.swift
//  ReceiptsSorted
//
//  Created by Maksim on 24/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit

class TopGraphicsView: UIView {
    
    private var viewWidth: CGFloat!
    private var viewHeight: CGFloat!
    
    private var indicatorCircle: CAShapeLayer!
    private var amountSumLabel: UILabel!
    
    var amountAnimation: AmountAnimation!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.viewWidth = frame.size.width
        self.viewHeight = frame.size.height
        
        configureUI()
        createBindings()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func createBindings() {
        amountAnimation = AmountAnimation(animationCircle: indicatorCircle)

        amountAnimation.overallAmount.onValueChanged { [unowned self] in
            self.amountSumLabel.text = "£\($0.pendingNumberRepresentation())"
        }
    }
    
    
    
    private func configureUI() {
        /* Create circles; region is [-pi/2 ; pi*3/2] */
        let mainGraphics = TopGraphicsShapes(frameWidth: viewWidth, frameHeight: viewHeight)
        let contourCircle = mainGraphics.createCircleLine(from: -CGFloat.pi/2, to: CGFloat.pi*3/2, ofColour: UIColor.contourFlatColour.cgColor)
        indicatorCircle = mainGraphics.createCircleLine(from: -CGFloat.pi/2, to: CGFloat.pi*3/2, ofColour: UIColor.flatOrange.cgColor)
        
        layer.addSublayer(contourCircle)
        layer.addSublayer(indicatorCircle)
        
        contourCircle.applyShadow(color: .black, alpha: 0.16, x: 2, y: 2, blur: 3)
        indicatorCircle.applyShadow(color: .flatOrange, alpha: 0.7, x: 0, y: 1, blur: 6)
        
        
        /* Creating Currency Label inside the circle */
        let currencyLabel = mainGraphics.createCurrencyLabel()
        addSubview(currencyLabel)

        
        
        
        /* Creating Amount sum label that will show sum of all pending payments */
        amountSumLabel = mainGraphics.createLabel(text: "£test")
        addSubview(amountSumLabel)
        
        let offsetRight: CGFloat = 25
        
        amountSumLabel.translatesAutoresizingMaskIntoConstraints = false
        amountSumLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -offsetRight).isActive = true
        amountSumLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -mainGraphics.circleRightSideOffset-2*offsetRight).isActive = true
        amountSumLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true
        amountSumLabel.centerYAnchor.constraint(equalTo: currencyLabel.centerYAnchor, constant: -mainGraphics.circleRadius*3/4).isActive = true
        
        
        /* Creating "Pending:" UILabel */
        let pendingLabel = mainGraphics.createLabel(text: "Pending:", textAlignment: .left)
        addSubview(pendingLabel)
        
        pendingLabel.translatesAutoresizingMaskIntoConstraints = false
        pendingLabel.rightAnchor.constraint(equalTo: amountSumLabel.rightAnchor).isActive = true
        pendingLabel.heightAnchor.constraint(equalTo: amountSumLabel.heightAnchor).isActive = true
        pendingLabel.widthAnchor.constraint(equalTo: amountSumLabel.widthAnchor).isActive = true
        pendingLabel.centerYAnchor.constraint(equalTo: amountSumLabel.centerYAnchor).isActive = true
        
        
        
        
        let contourBar = mainGraphics.createHorizontalBar(colour: .contourFlatColour, offset: offsetRight)
        let dayBar = mainGraphics.createHorizontalBar(percentage: 0.85, colour: .flatOrange, offset: offsetRight)
        layer.addSublayer(contourBar)
        layer.addSublayer(dayBar)
        contourBar.applyShadow(color: .black, alpha: 0.16, x: 2, y: 2, blur: 3)
        dayBar.applyShadow(color: .flatOrange, alpha: 0.7, x: 0, y: 1, blur: 6)
        
        
        let daysLeftLabel = UILabel(frame: CGRect(x: contourBar.frame.origin.x,
                                                  y: contourBar.frame.origin.y - 25,
                                                  width: contourBar.frame.width,
                                                  height: 17))
        daysLeftLabel.text = "1 out of 7 days left"
        daysLeftLabel.textColor = UIColor(rgb: 0xC6CACE)
        daysLeftLabel.font = UIFont.arial(ofSize: 15)
        daysLeftLabel.textAlignment = .center
        
        addSubview(daysLeftLabel)
    }
}
