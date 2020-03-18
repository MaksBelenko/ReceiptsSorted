//
//  EmailViewModel.swift
//  ReceiptsSorted
//
//  Created by Maksim on 16/03/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import MessageUI

class EmailViewModel: NSObject, MFMailComposeViewControllerDelegate {
    
    
    
    func sendMail() -> MFMailComposeViewController {
        
        let mailPicker = MFMailComposeViewController()
        
        mailPicker.mailComposeDelegate = self
        
        mailPicker.addAttachmentData(UIImage(named: "PictureMain")!.jpegData(compressionQuality: CGFloat(1.0))!, mimeType: "image/jpeg", fileName:  "test.jpeg")
        
        mailPicker.setSubject("subjectText")
        mailPicker.setMessageBody("TEST BODY", isHTML: true)
            
//        callingView.present(mailPicker, animated: true, completion: nil)
        return mailPicker
    }
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
