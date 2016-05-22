//
//  ChatTextCell.swift
//  HootsuiteChat
//
//  Created by apple on 21/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit


class ChatTextCell : UITableViewCell, UITextViewDelegate {
    @IBOutlet var iconImage : UIImageView?
    @IBOutlet var textMessage : UITextView?
    @IBOutlet var lblName : UILabel?
    @IBOutlet var lblTime : UILabel?
    @IBOutlet var inputTextHeight : NSLayoutConstraint?
    
    func fill(data : Message) {
        textMessage?.text = data.text
        inputTextHeight?.constant = textMessage?.contentSize.height ?? 24
        self.contentView.frame.size.height = (textMessage?.contentSize.height ?? 60) + 20
        lblName?.text = data.userID
    
        let date = NSDate(timeIntervalSince1970: data.sendIn)
        print("Time : \(date.description)")
        lblTime?.text = NSDate().offsetFrom(date)
        config()
        if let url = NSURL(string: data.avatarURL) {
            iconImage?.sd_setImageWithURL(url, placeholderImage: UIImage(named : "placeholderAvatar"))
        }
    }
    
    private func config(){
        configImage()
    }
    
    private func configImage(){
        iconImage?.layer.cornerRadius = 2.0
        iconImage?.layer.masksToBounds = true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //if(textView.contentSize.height > 31) {
           // inputTextHeight?.constant = textView.contentSize.height
        //}
        return true
    }
    
}


