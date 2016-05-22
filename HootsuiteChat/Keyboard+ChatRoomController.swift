//
//  Keyboard+ChatRoomController.swift
//  HootsuiteChat
//
//  Created by apple on 22/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit

extension ChatRoomController {
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.keyboardInputConstraint?.constant = keyboardFrame.size.height
        }) { status in
            if status {
                self.goToBottom()
            }
        }
    }
    
    func keyboardHide(notification: NSNotification) {
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.keyboardInputConstraint?.constant = 0
        }) { status in
            if status {
                self.goToBottom()
            }
        }
        
    }
}
