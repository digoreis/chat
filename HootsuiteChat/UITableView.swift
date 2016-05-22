//
//  UITableView.swift
//  HootsuiteChat
//
//  Created by apple on 22/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import Foundation


extension UITableView {
    
    func scrollToBottom(){
        let offSetY = self.contentSize.height - self.frame.size.height + self.contentInset.bottom
        UIView.animateWithDuration(0.33) {
            self.setContentOffset(CGPoint(x: 0, y: offSetY), animated: false)
        }
    }
}