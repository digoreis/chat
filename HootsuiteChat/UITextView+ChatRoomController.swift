//
//  UITextView+ChatRoomController.swift
//  HootsuiteChat
//
//  Created by apple on 22/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit
import FirebaseAuth


extension ChatRoomController {
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
        startTyping(FIRAuth.auth()?.currentUser?.displayName ?? "Anonymous")
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Say anything ..."
        }
        stopTyping(FIRAuth.auth()?.currentUser?.displayName ?? "Anonymous")
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let changeValue = textView.contentSize.height  - (inputTextHeight?.constant ?? 0)
        inputTextHeight?.constant = textView.contentSize.height
        viewInputTextHeight?.constant = (viewInputTextHeight?.constant ?? 0) + changeValue
        UIView.animateWithDuration(0.33) {
            self.view.layoutIfNeeded()
        }
        
        if ((textView.text.characters.count + text.characters.count) <= 200) {
            return true
        }
        
        return false
    }

}
