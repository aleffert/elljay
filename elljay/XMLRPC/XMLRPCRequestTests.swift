//
//  XMLRPCRequestTests.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

class XMLRPCRequestTests: XCTestCase {

    func testInt() {
        XCTAssertEqual(XMLRPCParam.XInt(3).toXMLNode().description, "<int>3</int>", "Positive integers convert to XML")
        XCTAssertEqual(XMLRPCParam.XInt(-3).toXMLNode().description, "<int>-3</int>", "Negative Integers convert to XML")
    }
    
    func testBool() {
        XCTAssertEqual(XMLRPCParam.XBoolean(false).toXMLNode().description, "<boolean>0</boolean>", "false converts to XML")
        XCTAssertEqual(XMLRPCParam.XBoolean(true).toXMLNode().description, "<boolean>1</boolean>", "true converts to XML")
    }
    
    func testString() {
        XCTAssertEqual(XMLRPCParam.XString("foo").toXMLNode().description, "<string>foo</string>", "Basic strings convert to XML")
        XCTAssertEqual(XMLRPCParam.XString("foo < bar & baz").toXMLNode().description, "<string>foo &lt; bar &amp; baz</string>", "Strings are properly escaped")
    }
    
    func testDouble() {
        XCTAssertEqual(XMLRPCParam.XDouble(3.25).toXMLNode().description, "<double>3.25</double>", "Doubles convert to XML")
        XCTAssertEqual(XMLRPCParam.XDouble(3.1).toXMLNode().description, "<double>3.1</double>", "Converted doubles round reasonably")
        // We'd like to check for nan and isinf here, but it looks swift doesn't handle the assertion cases
        // We could use an option for toXMLNode, but those seem like exceptional cases not worth polluting the interface for
    }
    
    func testArray() {
        let array = XMLRPCParam.XArray([XMLRPCParam.XString("foo"), XMLRPCParam.XBoolean(true)])
        XCTAssertEqual(array.toXMLNode().description, "<array><data><value><string>foo</string></value><value><boolean>1</boolean></value></data></array>", "Arrays convert to XML")
    }
    
    func testStruct() {
        let array = XMLRPCParam.XStruct(["a" : XMLRPCParam.XString("foo"), "b" : XMLRPCParam.XBoolean(true)])
        XCTAssertEqual(array.toXMLNode().description, "<struct><member><name>a</name><value><string>foo</string></value></member><member><name>b</name><value><boolean>1</boolean></value></member></struct>", "Structs convert to XML")
    }
    
    func testDateTime() {
        let components = NSDateComponents()
        components.timeZone = NSCalendar.currentCalendar().timeZone
        components.day = 17
        components.month = 7
        components.year = 1998
        components.hour = 14
        components.minute = 8
        components.second = 55
        let calendar = NSCalendar(identifier: NSGregorianCalendar)
        calendar.timeZone = NSCalendar.currentCalendar().timeZone
        let date = calendar.dateFromComponents(components)
        let dateNode = XMLRPCParam.XDateTime(date)
        XCTAssertEqual(dateNode.toXMLNode().description, "<dateTime.iso8601>19980717T14:08:55</dateTime.iso8601>", "ISO Dates convert to XML")
    }

}
