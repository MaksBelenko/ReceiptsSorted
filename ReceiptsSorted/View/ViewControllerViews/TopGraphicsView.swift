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
    private var dayBar: CALayer!
    private var amountSumLabel: UILabel!
    private var currencyLabel: UILabel!
    private var daysLeftLabel: UILabel!
//    private let indicatorColour = UIColor.flatOrange.resolvedColor(with: self.traitCollection).cgColor
    
    private let settings = SettingsUserDefaults.shared
    
    var amountAnimation: AmountAnimation!
    var dateAnimation: DateAnimation!
    
    

    // MARK: - Lifecycle
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
    
    
//    deinit {
//        SettingsUserDefaults.shared.removeCurrencyListener(self)
//    }
    

    // MARK: - Configureations
    
    private func createBindings() {
        amountAnimation = AmountAnimation(animationCircle: indicatorCircle)
        amountAnimation.overallAmount.onValueChanged { [unowned self] in
            self.amountSumLabel.text = $0.pendingNumberRepresentation() //"\(self.amountSumSymbol)\($0.pendingNumberRepresentation())"
        }
        
        dateAnimation = DateAnimation(dateIndicator: dayBar)
        dateAnimation.daysLeftAnimField.onValueChanged { [unowned self] in
            let maxDays = Int(self.dateAnimation.maxDays)
            self.daysLeftLabel.text = "\($0) of \(maxDays) days left"
        }
    }
    
    // MARK: - UI Configuration
    
    private func configureUI() {
        /* Create circles; region is [-pi/2 ; pi*3/2] */
        let mainGraphics = TopGraphicsShapes(frameWidth: viewWidth, frameHeight: viewHeight)
        let contourCircle = mainGraphics.createCircleLine(from: -CGFloat.pi/2, to: CGFloat.pi*3/2, ofColour: UIColor.indicatorContourFlatColour.cgColor)
        indicatorCircle = mainGraphics.createCircleLine(from: -CGFloat.pi/2, to: CGFloat.pi*3/2, ofColour: UIColor.flatOrange.resolvedColor(with: self.traitCollection).cgColor)
        
        layer.addSublayer(contourCircle)
        layer.addSublayer(indicatorCircle)
        
        contourCircle.applyShadow(color: .black, alpha: 0.16, x: 2, y: 2, blur: 3)
        indicatorCircle.applyShadow(color: .flatOrange, alpha: 0.7, x: 0, y: 1, blur: 6)
        
        
        /* Creating Currency Label inside the circle */
        currencyLabel = mainGraphics.createCurrencyLabel()
        setCurrencyLabelText(with: settings.getCurrency().symbol!)
        addSubview(currencyLabel)

        
        
        
        /* Creating Amount sum label that will show sum of all pending payments */
        amountSumLabel = mainGraphics.createLabel(text: "£test")
        addSubview(amountSumLabel)
        
        let offsetRight: CGFloat = 25
        
        amountSumLabel.translatesAutoresizingMaskIntoConstraints = false
        amountSumLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -offsetRight).isActive = true
        amountSumLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -mainGraphics.circleRightSideOffset-2*offsetRight).isActive = true
        amountSumLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true
        amountSumLabel.centerYAnchor.constraint(equalTo: currencyLabel.centerYAnchor, constant: -mainGraphics.circleRadius*2/4).isActive = true
        
        
        /* Creating "Pending:" UILabel */
        let pendingLabel = mainGraphics.createLabel(text: "Pending:", textAlignment: .left)
        addSubview(pendingLabel)
        
        pendingLabel.translatesAutoresizingMaskIntoConstraints = false
        pendingLabel.rightAnchor.constraint(equalTo: amountSumLabel.rightAnchor).isActive = true
        pendingLabel.heightAnchor.constraint(equalTo: amountSumLabel.heightAnchor).isActive = true
        pendingLabel.widthAnchor.constraint(equalTo: amountSumLabel.widthAnchor).isActive = true
        pendingLabel.centerYAnchor.constraint(equalTo: amountSumLabel.centerYAnchor).isActive = true
        
        
        
        /* Creating days bar */
        let contourBar = mainGraphics.createHorizontalBar(colour: .indicatorContourFlatColour, offset: offsetRight)
        dayBar = mainGraphics.createHorizontalBar(percentage: 1, colour: .flatOrange, offset: offsetRight)
        layer.addSublayer(contourBar)
        layer.addSublayer(dayBar)
        contourBar.applyShadow(color: .black, alpha: 0.16, x: 2, y: 2, blur: 3)
        dayBar.applyShadow(color: .flatOrange, alpha: 0.7, x: 0, y: 1, blur: 6)


        daysLeftLabel = UILabel(frame: CGRect(x: contourBar.frame.origin.x,
                                                  y: contourBar.frame.origin.y - 25,
                                                  width: contourBar.frame.width,
                                                  height: 17))
        daysLeftLabel.text = "1 out of 7 days left"
        daysLeftLabel.textColor = UIColor(rgb: 0xC6CACE)
        daysLeftLabel.font = UIFont.arial(ofSize: 15)
        daysLeftLabel.textAlignment = .center

        addSubview(daysLeftLabel)

//        daysLeftLabel.alpha = 0
//        dayBar.backgroundColor = UIColor.clear.cgColor
//        contourBar.backgroundColor = UIColor.clear.cgColor
    }
}


// MARK: - CurrencyChangedProtocol
extension TopGraphicsView {

    func setCurrencyLabelText(with currencySymbol: String) {
        currencyLabel.font = (currencySymbol.count > 2) ? UIFont.arial(ofSize: 30) : UIFont.arial(ofSize: 46)
        currencyLabel.text = currencySymbol
    }
}


// MARK: - TraitCollection
extension TopGraphicsView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                
                let flatOrangeCgColor = UIColor.flatOrange.cgColor
                indicatorCircle.strokeColor = flatOrangeCgColor
                indicatorCircle.shadowColor = flatOrangeCgColor
                
                dayBar.backgroundColor = flatOrangeCgColor
                dayBar.shadowColor = flatOrangeCgColor
            }
        }
    }
}
