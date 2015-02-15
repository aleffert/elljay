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
    func testGetChallengeParser() {
        let service = LJService()
        let (_, parser) = service.getChallenge()
        
        let (date, challenge, params) = LJServiceTestHelpers.challenge()
        let result = parser(params.toResponseData())
        
        switch(result) {
        case let .Success(r):
            XCTAssertEqual(r.value.challenge, challenge)
            XCTAssertEqual(r.value.expireTime, date)
            XCTAssertEqual(r.value.serverTime, date)
        case let .Failure(error):
            XCTFail("Bad parse: \(error)")
        }
        
    }

    func testLoginParser() {
        let service = LJService()
        let date = LJServiceTestHelpers.standardTestDate()
        let request = service.login()
        
        let fullName = "Akiva Leffert"
        let result = request.parser(XMLRPCParam.XStruct([
            "fullname" : XMLRPCParam.XString(fullName)
            ]).toResponseData())
        switch(result) {
        case let .Success(r):
            XCTAssertEqual(r.value.fullname, fullName)
        case let .Failure(error):
            XCTFail("Bad parse: \(error)")
        }
    }
    
    func testSyncItemsParser() {
        let service = LJService()
        let date = LJServiceTestHelpers.standardTestDate()
        let request = service.syncItems()
        
        let item = "L-100"
        let count : Int32 = 10
        let total : Int32 = 20
        let response : XMLRPCParam = XMLRPCParam.XStruct([
            "syncitems" : XMLRPCParam.XArray([
                XMLRPCParam.XStruct([
                    "item" : XMLRPCParam.XString(item),
                    "action" : XMLRPCParam.XString("create"),
                    "time" : XMLRPCParam.XString(DateUtils.stringFromDate(date))])]),
            "count" : XMLRPCParam.XInt(count),
            "total" : XMLRPCParam.XInt(total)
            ])
        let result = request.parser(response.toResponseData())
        switch(result) {
        case let .Success(r):
            XCTAssertEqual(r.value.total, total)
            XCTAssertEqual(r.value.count, count)
            XCTAssertEqual(r.value.syncitems.count, 1)
            let i = r.value.syncitems[0]
            XCTAssertEqual(i.action, LJService.SyncAction.Create)
            XCTAssertEqual(i.item.type, LJService.SyncType.Journal)
            XCTAssertEqual(i.item.index, 100 as Int32)
        case let .Failure(e):
            XCTFail("Bad parse: \(e)")
        }
    }

    func testGetFriendsParser() {
        let service = LJService()
        let request = service.getFriends()
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
        switch(result) {
        case let .Success(r):
            XCTAssertEqual(countElements(r.value.friends), 2)
        case let .Failure(e):
            XCTFail("Bad parse: \(e)")
        }
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
        switch(result) {
        case let .Success(r):
            XCTAssertEqual(countElements(r.value.entries), 2)
            let item = r.value.entries[0]
            XCTAssertEqual(item.title!, "Some Title")
            XCTAssertEqual(countElements(item.tags), 3)
            XCTAssertTrue(find(item.tags, "foo") != nil)
            XCTAssertTrue(find(item.tags, "bar") != nil)
            XCTAssertTrue(find(item.tags, "some tag") != nil)
            XCTAssertTrue(find(item.tags, "something else") == nil)
            let otherItem = r.value.entries[1]
            XCTAssertEqual(otherItem.title!, "Other Title")
            XCTAssertTrue(otherItem.date.matches(year: 2013, month: 11, dayOfMonth: 15))
        case let .Failure(e):
            XCTFail("Bad parse: \(e)")
        }
    }

}
