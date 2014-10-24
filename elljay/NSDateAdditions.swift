//
//  NSDateAdditions.swift
//  elljay
//
//  Created by Akiva Leffert on 8/30/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit


public func < (left : NSDate, right : NSDate) -> Bool {
    return left.compare(right) == NSComparisonResult.OrderedAscending
}

public func == (left : NSDate, right : NSDate) -> Bool {
    return left.isEqualToDate(right)
}

extension NSDate : Equatable {
}

extension NSDate : Comparable {
}

extension NSDate {
    func matches(#year : Int, month : Int, dayOfMonth : Int, timeZone : NSTimeZone = NSTimeZone(forSecondsFromGMT:0), calendarIdentifier : String = NSCalendarIdentifierGregorian) -> Bool {
        let calendar = NSCalendar(identifier:calendarIdentifier)!
        calendar.timeZone = timeZone
        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate:self)
        return components.year == year && components.month == month && components.day == dayOfMonth
    }
}