//
//  ServiceTests.swift
//  elljay
//
//  Created by Akiva Leffert on 8/27/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest
import elljay

class ServiceTests: XCTestCase {
    
    func standardTestDate() -> NSDate {
        let components = NSDateComponents()
        components.month = 12
        components.day = 7
        components.year = 1983
        let date = NSCalendar.autoupdatingCurrentCalendar().dateFromComponents(components)!
        return date
    }

    func testGetChallengeParser() {
        let date = standardTestDate()
        let epochDate = Int32(date.timeIntervalSince1970)
        
        let service = Service()
        let request = service.getChallenge()
        
        let challenge = "c0:1073113200:2831:60:2TCbFBYR72f2jhVDuowz:0fba728f5964ea54160a5b18317d92df"
        let result = request.parser(XMLRPCParam.XStruct(
            [
                "challenge" : XMLRPCParam.XString(challenge),
                "expire_time" : XMLRPCParam.XInt(epochDate),
                "server_time" : XMLRPCParam.XInt(epochDate)
            ]))
        
        XCTAssertEqual(result!.challenge, challenge)
        XCTAssertEqual(result!.expireTime, date)
        XCTAssertEqual(result!.serverTime, date)
        
    }

    func testLoginParser() {
        let service = Service()
        let date = standardTestDate()
        let request = service.login(AuthSessionInfo(username: "foo", password: "bar", challenge: "baz", challengeExpiration: date))
        
        let fullName = "Akiva Leffert"
        let result = request.parser(XMLRPCParam.XStruct([
            "fullname" : XMLRPCParam.XString(fullName)
            ]))
        XCTAssertEqual(result!.fullname, fullName)
    }

}
