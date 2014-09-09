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
        let (_, parser) = service.getChallenge()
        
        let challenge = "c0:1073113200:2831:60:2TCbFBYR72f2jhVDuowz:0fba728f5964ea54160a5b18317d92df"
        let result = parser(XMLRPCParam.XStruct(
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
        let request = service.login()
        
        let fullName = "Akiva Leffert"
        let result = request.parser(XMLRPCParam.XStruct([
            "fullname" : XMLRPCParam.XString(fullName)
            ]))
        XCTAssertEqual(result!.fullname, fullName)
    }
    
    func testSyncItemsParser() {
        let service = Service()
        let date = standardTestDate()
        let request = service.syncitems()
        
        let item = "Item"
        let type = "Type"
        let count : Int32 = 10
        let total : Int32 = 20
        let response : XMLRPCParam = XMLRPCParam.XStruct([
            "syncitems" : XMLRPCParam.XArray([XMLRPCParam.XStruct(["item" : XMLRPCParam.XString(item), "type" : XMLRPCParam.XString(type)])]),
            "count" : XMLRPCParam.XInt(count),
            "total" : XMLRPCParam.XInt(total)
            ])
        let result : Service.SyncItemsResponse? = request.parser(response)
        XCTAssert(result != nil)
        XCTAssertEqual(result!.total, total)
        XCTAssertEqual(result!.count, count)
        XCTAssertEqual(result!.syncitems.count, 1)
    }

}
