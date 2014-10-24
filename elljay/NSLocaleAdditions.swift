//
//  NSLocaleAdditions.swift
//  elljay
//
//  Created by Akiva Leffert on 10/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

extension NSLocale {
    public class func usEnglishLocale() -> NSLocale {
        return NSLocale(localeIdentifier: "en_US")
    }
}