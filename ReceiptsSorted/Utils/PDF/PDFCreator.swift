//
//  PDFCreator.swift
//  PaymentsPDF
//
//  Created by Maksim on 04/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import PDFKit

class PDFCreator: NSObject {

    var companyLogo: UIImage = #imageLiteral(resourceName: "NameLogo")
    
    let pageOffset: (top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) = (top: 36, bottom: 36, left: 36, right: 36)  //Half an inch each
    let tableRowHeight: CGFloat = 20
    let tableHeaderFont = UIFont(name: "HelveticaNeue-Bold", size: 12)!
    static let tableRowsFont = UIFont(name: "Helvetica Neue", size: 10)!
    
    private var shapes: SimpleShapes!
    
    var dateToday: String {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return "\(day.numberAbbreviation()) of \(month.mapToMonth()) \(year)"
    }
    
    private var payments: [Payments]!
    
    private var pageNumber = 1
    
    
    
    
    
    //MARK: - Initialiser
    init(payments: [Payments]) {
        self.payments = payments
        shapes = SimpleShapes(tableRowHeight: tableRowHeight, pageOffset: pageOffset)
    }
    
    
    
    
    //MARK: - PDF Creation
    
    /**
     Create PDF file data
     */
    func createPDF() -> Data {
        let pdfMetaData = [ kCGPDFContextCreator: "ReceiptsSorted",
                            kCGPDFContextAuthor:  "Maksim Belenko",
                            kCGPDFContextTitle:   "Payments of Maksim Belenko" ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        // PDF files use a coordinate system with 72 points per inch
        let pageWidth = 8.27 * 72.0      //A4 format is 8.27 inches in width
        let pageHeight = 11.69 * 72.0     //A4 format is 11.69 inches in height
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            self.drawPDF(context: context, pageRect: pageRect)
        }

        return data
    }

    
    
    
    /**
     Draws all the content of the PDF file
     */
    private func drawPDF(context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
        context.beginPage() //new page
                    
        // Draw Company logo (top right)
        let imageBottom = drawImage(image: companyLogo, pageRect: pageRect, imageTop: pageOffset.top, width: pageRect.width * 0.3, alignment: .right)
        
        // Draw date (under company logo)
        let titleBottom = addSingleLineText(text: "Date: \(dateToday)", font: UIFont(name: "Helvetica Neue", size: 16)!, pageRect: pageRect, alignment: .right, top: imageBottom + 36)
        
        // Draw table header with text
        let headerBottom = drawHeader(drawContext: context.cgContext, pageRect: pageRect, top: titleBottom + 36)
        
        // Draw Table Rows
        var newTop = headerBottom
        for i in 0..<payments.count {
            newTop = drawTableRow(payment: payments[i], even: i%2>0, drawContext: context.cgContext, pageRect: pageRect, top: newTop)
            // check bottom border
            if (newTop > (pageRect.height - (tableRowHeight + pageOffset.bottom)) ) {
                startNewPage(context: context, pageRect: pageRect)
                newTop = pageOffset.top
            }
        }
        
        // Draw photos of the receipts at the end
        for p in payments {
            startNewPage(context: context, pageRect: pageRect)
            drawImage(image: UIImage(data: p.receiptPhoto!)!, pageRect: pageRect, imageTop: pageOffset.top, width: pageRect.width*0.7, alignment: .centre)
        }
        
        //Number last page
        numberThePage(pageRect: pageRect)
        
//       addBodyText(pageRect: pageRect, textTop: titleBottom + 18.0)

    }
    
    
    /**
     Creates new page and numbers the current page
     */
    private func startNewPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
        numberThePage(pageRect: pageRect)
        context.beginPage() //new page
    }
    
    /**
     Numbers the page and increases the page counter
     */
    private func numberThePage(pageRect: CGRect) {
        addSingleLineText(text: "Page: \(pageNumber)", font: PDFCreator.tableRowsFont, pageRect: pageRect, alignment: .right, top: pageRect.height - pageOffset.bottom + 7)
        pageNumber += 1
    }

    
    
    //MARK: - Header Drawing
    
    /**
    Draw header for table
    - Parameter drawContext: Core Graphics context
    - Parameter pageRect: Page size rectangle
    - Parameter top: Top Offset
    */
    private func drawHeader(drawContext: CGContext, pageRect: CGRect, top: CGFloat) -> CGFloat {
        drawHeaderRect(drawContext: drawContext, pageRect: pageRect, top: top)
        
        addTableText(text: "Date",  textColour: .white, font: tableHeaderFont, columnType: .Date,  pageRect: pageRect, top: top + 2)
        addTableText(text: "Place", textColour: .white, font: tableHeaderFont, columnType: .Place, pageRect: pageRect, top: top + 2)
        addTableText(text: "Price", textColour: .white, font: tableHeaderFont, columnType: .Price, pageRect: pageRect, top: top + 2)
        
        return top + tableRowHeight
    }
    
    
    
    /**
    Draw header rectangle with separator lines
    - Parameter drawContext: Core Graphics context
    - Parameter pageRect: Page size rectangle
    - Parameter top: Top Offset
    */
    private func drawHeaderRect(drawContext: CGContext, pageRect: CGRect, top: CGFloat) {
        shapes.drawRectWithCornerRadius(drawContext: drawContext, pageRect: pageRect, top: top)
        shapes.drawTableColumnsSeparators(drawContext: drawContext, pageRect: pageRect, top: top)
    }
    
    
    
    
    //MARK: - Table row drawing
    
    /**
     Draws table row with its data
     - Parameter payment: Payment information
     - Parameter even: Shows if the row is even and therefore the rectangle will be drawn
     - Parameter drawContext: Core Graphics context
     - Parameter pageRect: Page size rectangle
     - Parameter top: Top Offset
     */
    private func drawTableRow(payment: Payments, even: Bool, drawContext: CGContext, pageRect: CGRect, top: CGFloat) -> CGFloat {
        if even == true {
            shapes.drawRectWithCornerRadius(drawContext: drawContext, pageRect: pageRect, top: top, colour: .superLightFlatOrange)
        }
        
        addTableText(text: (payment.date?.toDateString())!,                columnType: .Date,  pageRect: pageRect, top: top + 4)
        addTableText(text: payment.place!,                                 columnType: .Place, pageRect: pageRect, top: top + 4)
        addTableText(text: "£\(payment.amountPaid.ToString(decimals: 2))", columnType: .Price, pageRect: pageRect, top: top + 4)
        
        return top + tableRowHeight
    }
    
    
    
    
    
    // MARK: - Text Drawing
    
    /**
     Use to create text for the row using payment information
     - Parameter text: Text that should be presented
     - Parameter textColour: Colour of the text (Default is black)
     - Parameter font: Font of the text (Default is tableRowsFont property)
     - Parameter columnType: Enum to get specific location in the row
     - Parameter pageRect: Page size rectangle
     - Parameter top: Top Offset
     */
    private func addTableText(text: String, textColour: UIColor = .black,
                              font: UIFont = tableRowsFont, columnType: TableColumn,
                              pageRect: CGRect, top: CGFloat) {
        
        let textAttributes = [NSAttributedString.Key.foregroundColor : textColour,
                              NSAttributedString.Key.font: font]
        
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        let textStringSize = attributedText.size()

        let offsetX = getOffsetX(column: columnType, textWidth: textStringSize.width, pageRect: pageRect)
        let textStringRect = CGRect(x: offsetX, y: top, width: textStringSize.width, height: textStringSize.height)

        attributedText.draw(in: textStringRect)
    }
    
    
    
    /**
     Helper method to get the X-coordinate offset for different columns
     - Parameter column: Enum to get specific location in the row
     - Parameter textWidth: Width of the text
     - Parameter pageRect: Page size rectangle
     */
    private func getOffsetX(column: TableColumn, textWidth: CGFloat, pageRect: CGRect) -> CGFloat {
        switch column {
        case .Date:
            return pageOffset.left + 10
        case .Place:
            return pageOffset.left + 150
        case .Price:
            return pageRect.width - (textWidth + pageOffset.right + 10)
        }
    }
    
    
    
    
    
    /**
     Use to add a single line of text with alignment in the page
     - Parameter text: Text that should be presented
     - Parameter textColour: Colour of the text (Default is black)
     - Parameter font: Font of the text (Default is tableRowsFont property)
     - Parameter pageRect: Page size rectangle
     - Parameter alignment: Enum to show the alignment of the text relative to the page
     - Parameter top: Top Offset
     */
    private func addSingleLineText(text: String, textColour: UIColor = .black, font: UIFont, pageRect: CGRect, alignment: Alignment, top: CGFloat) -> CGFloat {
        let textAttributes = [NSAttributedString.Key.foregroundColor : textColour, NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        let textStringSize = attributedText.size()

        let textX = getAlignedPositionX(alignment: alignment, pageRect: pageRect, width: textStringSize.width)
        let textStringRect = CGRect(x: textX, y: top, width: textStringSize.width, height: textStringSize.height)

        attributedText.draw(in: textStringRect)

        return textStringRect.origin.y + textStringRect.size.height
    }
    
    
    
    
    
    /**
     Use to add text that is long and therefore might be wrapped
     - Parameter text: Text that should be presented
     - Parameter pageRect: Page size rectangle
     - Parameter textTop: Top Offset
     */
    private func addWrappingText(text: String, pageRect: CGRect, textTop: CGFloat) {
        let textFont = UIFont.systemFont(ofSize: 18.0, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let textAttributes = [ NSAttributedString.Key.paragraphStyle: paragraphStyle,
                               NSAttributedString.Key.font: textFont ]

        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        
        let textWidth = pageRect.width - (pageOffset.left + pageOffset.right)
        let textHeight = pageRect.height - textTop - pageRect.height / 5.0
        let textRect = CGRect(x: pageOffset.left, y: textTop, width: textWidth, height: textHeight)
      
        attributedText.draw(in: textRect)
    }
    
    
    
    
    
    //MARK: - Image Drawing
    
    /**
    Draws and image to the PDF
    - Parameter image: UIImage to be drawn
    - Parameter pageRect: Page size rectangle
    - Parameter imageTop: Top Offset
    - Parameter width: Width that the image should be
    - Parameter alignment: Enum to show the alignment of the image relative to the page
    */
    private func drawImage(image: UIImage, pageRect: CGRect, imageTop: CGFloat, width: CGFloat, alignment: Alignment) -> CGFloat {
        let maxHeight = pageRect.height * 0.5
//        let maxWidth = pageRect.width * 0.8

        let aspectWidth = width / image.size.width
        let aspectHeight = maxHeight / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.height * aspectRatio
        
        let imageX = getAlignedPositionX(alignment: alignment, pageRect: pageRect, width: scaledWidth)
        let imageRect = CGRect(x: imageX, y: imageTop, width: scaledWidth, height: scaledHeight)

        image.draw(in: imageRect)
        return imageRect.origin.y + imageRect.size.height
    }

    
    
    
    /**
     Helper method to get X-Coordinate offset
     - Parameter alignment: Enum to show the alignment of the image relative to the page
     - Parameter pageRect: Page size rectangle
     - Parameter width: Width of the image
     */
    private func getAlignedPositionX(alignment: Alignment, pageRect: CGRect, width: CGFloat) -> CGFloat {
        switch alignment
        {
        case .left:
            return pageOffset.left // half od an inch
        case .centre:
            return (pageRect.width - width) / 2.0
        case .right:
            return pageRect.width - width - pageOffset.right
        }
    }

}

