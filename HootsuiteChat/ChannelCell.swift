//
//  ChannelCell.swift
//  HootsuiteChat
//
//  Created by apple on 21/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit
import QuartzCore

class ChannelCell : UITableViewCell {
    @IBOutlet var  viewContainer: UIView?
    @IBOutlet var lblNameChannel : UILabel?
    @IBOutlet var lblCreateBy : UILabel?
    @IBOutlet var lblTextTopic : UILabel?
    
    let colors = [
                  UIColor.hexColor("#AEC6CF"),
                  UIColor.hexColor("#DEA5A4"),
                  UIColor.hexColor("#B39EB5"),
                  UIColor.hexColor("#FFB347"),
                  UIColor.hexColor("#77DD77"),
                  UIColor.hexColor("#F49AC2"),
                  UIColor.hexColor("#FF6961")
                ]
    
    func fill(data : Channel) {
        configContainer()
        lblNameChannel?.text = data.name
        lblCreateBy?.text = data.id
        lblTextTopic?.text = data.topic
    }
    private func configContainer() {
        viewContainer?.layer.cornerRadius = 2.0
        viewContainer?.layer.masksToBounds = true
        viewContainer?.backgroundColor = colors[randPosition()]
        
    }
    
    func randPosition() -> Int {
        return Int(rand()) % colors.count
    }
}

extension UIColor {
    class func hexColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}


