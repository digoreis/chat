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
    
    
    func fill(data : Channel) {
        configContainer()
        lblNameChannel?.text = data.name
        lblCreateBy?.text = data.id
        lblTextTopic?.text = data.topic
    }
    private func configContainer() {
        viewContainer?.layer.cornerRadius = 2.0
        viewContainer?.layer.masksToBounds = true
    }
}



