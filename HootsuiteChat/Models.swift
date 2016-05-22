//
//  Models.swift
//  HootsuiteChat
//
//  Created by apple on 22/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import Foundation



struct Message {
    let userID : String
    let text : String
    let sendIn : Double
    let avatarURL : String
}

struct Typing {
    let name : String
    let key : String
}

struct Channel {
    let key : String
    let id : String
    let name : String
    let topic : String
}

struct ChatRoom {
    
    let title : String
    let chatID : String
    let topic : String
}