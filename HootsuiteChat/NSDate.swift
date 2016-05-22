//
//  NSDate.swift
//  HootsuiteChat
//
//  Created by apple on 22/05/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import Foundation

extension NSDate {
    
    func offsetFrom(date:NSDate) -> String {
        
        let dayHourMinuteSecond: NSCalendarUnit = [.Day, .Hour, .Minute, .Second]
        let difference = NSCalendar.currentCalendar().components(dayHourMinuteSecond, fromDate: date, toDate: self, options: [])
        
        let seconds = "\(difference.second)s"
        let minutes = "\(difference.minute)m"
        let hours = "\(difference.hour)h"
        let days = "\(difference.day)d"
        
        if difference.day    > 0 { return days }
        if difference.hour   > 0 { return hours }
        if difference.minute > 0 { return minutes }
        if difference.second > 0 { return seconds }
        return "Now"
    }
    
}