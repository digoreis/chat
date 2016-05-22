//
//  Behavior+CharRoomController.swift
//  HootsuiteChat
//
//  Created by apple on 22/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import UIKit

extension ChatRoomController {
    
    func goToBottom(){
        tableView?.scrollToBottom()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0 : return list.count
        default : return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatTextCell") as? ChatTextCell ?? ChatTextCell(style: .Subtitle, reuseIdentifier: "ChatTextCell")
        cell.fill(list[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        goToBottom()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect.zero)
        headerView.userInteractionEnabled = false
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let size = tableView.frame.height -  CGFloat(list.count * 100)
        return size
    }
    
    
}
