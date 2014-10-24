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
        
        let service = LJService()
        let (_, parser) = service.getChallenge()
        
        let challenge = "c0:1073113200:2831:60:2TCbFBYR72f2jhVDuowz:0fba728f5964ea54160a5b18317d92df"
        let params = XMLRPCParam.XStruct(
            [
                "challenge" : XMLRPCParam.XString(challenge),
                "expire_time" : XMLRPCParam.XInt(epochDate),
                "server_time" : XMLRPCParam.XInt(epochDate)
            ])
        let result = parser(params.toResponseData())
        
        result.cata({r -> Void in
            XCTAssertEqual(r.challenge, challenge)
            XCTAssertEqual(r.expireTime, date)
            XCTAssertEqual(r.serverTime, date)
            return
        }, {error in
            XCTFail("Bad parse: \(error)")
            return
        })
        
    }

    func testLoginParser() {
        let service = LJService()
        let date = standardTestDate()
        let request = service.login()
        
        let fullName = "Akiva Leffert"
        let result = request.parser(XMLRPCParam.XStruct([
            "fullname" : XMLRPCParam.XString(fullName)
            ]).toResponseData())
        result.cata({r -> Void in
            XCTAssertEqual(r.fullname, fullName)
            return
        }, {error in
            XCTFail("Bad parse: \(error)")
            return
        })
    }
    
    func testSyncItemsParser() {
        let service = LJService()
        let date = standardTestDate()
        let request = service.syncitems()
        
        let item = "L-100"
        let count : Int32 = 10
        let total : Int32 = 20
        let response : XMLRPCParam = XMLRPCParam.XStruct([
            "syncitems" : XMLRPCParam.XArray([
                XMLRPCParam.XStruct([
                    "item" : XMLRPCParam.XString(item),
                    "action" : XMLRPCParam.XString("create"),
                    "time" : XMLRPCParam.XString(DateUtils.stringFromDate(standardTestDate()))])]),
            "count" : XMLRPCParam.XInt(count),
            "total" : XMLRPCParam.XInt(total)
            ])
        let result = request.parser(response.toResponseData())
        result.cata({r -> Void in
            XCTAssertEqual(r.total, total)
            XCTAssertEqual(r.count, count)
            XCTAssertEqual(r.syncitems.count, 1)
            let i = r.syncitems[0]
            XCTAssertEqual(i.action, LJService.SyncAction.Create)
            XCTAssertEqual(i.item.type, LJService.SyncType.Journal)
            XCTAssertEqual(i.item.index, 100 as Int32)
            return
        }, {error in
            XCTFail("Bad parse: \(error)")
            return
        })
    }

    func testGetFriendsParser() {
        let service = LJService()
        let request = service.getfriends()
        let total : Int32 = 2
        
        let response : XMLRPCParam = .XStruct([
            "friends" : .XArray([
                .XStruct([
                    "username" : .XString("aleffert"),
                    "fullname" : .XString("akiva")
                    ]),
                .XStruct([
                    "username" : .XString("treffela"),
                    "fullname" : .XString("avika")
                    ])
            ])
        ])

        let result = request.parser(response.toResponseData())
        result.cata({r -> Void in
            XCTAssertEqual(countElements(r.friends), 2)
            return
        }, {error in
            XCTFail("Bad parse: \(error)")
            return
        })
    }

    func testFeedParser() {
        let service = LJService()
        let request = service.feed("aleffert")
        
        let response = XMLDocument([
            XMLNode(name: "rss", children: [XMLNode(
                name : "channel",
                children: [
                    XMLNode(name: "item", children: [
                        XMLNode(name: "title", text: "Some Title"),
                        XMLNode(name: "category", text: "foo"),
                        XMLNode(name: "category", text: "bar"),
                        XMLNode(name: "category", text: "some tag"),
                        XMLNode(name: "pubDate", text: "Wed, 13 Nov 2013 03:09:16 GMT")
                        ]),
                    XMLNode(name: "item", children: [
                        XMLNode(name: "title", text: "Other Title"),
                        XMLNode(name: "pubDate", text: "Fri, 15 Nov 2013 12:12:16 GMT")
                        ])
                ]
                )])])
        let result = request.parser(response.toData())
        result.cata({r -> Void in
            XCTAssertEqual(countElements(r.entries), 2)
            let item = r.entries[0]
            XCTAssertEqual(item.title!, "Some Title")
            XCTAssertEqual(countElements(item.tags), 3)
            XCTAssertTrue(find(item.tags, "foo") != nil)
            XCTAssertTrue(find(item.tags, "bar") != nil)
            XCTAssertTrue(find(item.tags, "some tag") != nil)
            XCTAssertTrue(find(item.tags, "something else") == nil)
            let otherItem = r.entries[1]
            XCTAssertEqual(otherItem.title!, "Other Title")
            XCTAssertTrue(otherItem.date.matches(year: 2013, month: 11, dayOfMonth: 15))
        }, {error in
            XCTFail("Bad parse: \(error)")
        })
    }

}
