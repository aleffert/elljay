//
//  XMLRPCTests.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

import elljay

class XMLRPCRequestTests: XCTestCase {

    func testPrinterInt() {
        XCTAssertEqual(XMLRPCParam.XInt(3).toXMLNode().description, "<int>3</int>", "Positive integers convert to XML")
        XCTAssertEqual(XMLRPCParam.XInt(-3).toXMLNode().description, "<int>-3</int>", "Negative Integers convert to XML")
    }
    
    func testPrinterBool() {
        XCTAssertEqual(XMLRPCParam.XBoolean(false).toXMLNode().description, "<boolean>0</boolean>", "false converts to XML")
        XCTAssertEqual(XMLRPCParam.XBoolean(true).toXMLNode().description, "<boolean>1</boolean>", "true converts to XML")
    }
    
    func testPrinterString() {
        XCTAssertEqual(XMLRPCParam.XString("foo").toXMLNode().description, "<string>foo</string>", "Basic strings convert to XML")
        XCTAssertEqual(XMLRPCParam.XString("foo < bar & baz").toXMLNode().description, "<string>foo &lt; bar &amp; baz</string>", "Strings are properly escaped")
    }
    
    func testPrinterDouble() {
        XCTAssertEqual(XMLRPCParam.XDouble(3.25).toXMLNode().description, "<double>3.25</double>", "Doubles convert to XML")
        XCTAssertEqual(XMLRPCParam.XDouble(3.1).toXMLNode().description, "<double>3.1</double>", "Converted doubles round reasonably")
        // We'd like to check for nan and isinf here, but it looks swift doesn't handle the assertion cases
        // We could use an option for toXMLNode, but those seem like exceptional cases not worth polluting the interface for
    }
    
    func testPrinterArray() {
        let array = XMLRPCParam.XArray([XMLRPCParam.XString("foo"), XMLRPCParam.XBoolean(true)])
        XCTAssertEqual(array.toXMLNode().description, "<array><data><value><string>foo</string></value><value><boolean>1</boolean></value></data></array>", "Arrays convert to XML")
    }
    
    func testPrinterStruct() {
        let array = XMLRPCParam.XStruct(["a" : XMLRPCParam.XString("foo"), "b" : XMLRPCParam.XBoolean(true)])
        XCTAssertEqual(array.toXMLNode().description, "<struct><member><name>a</name><value><string>foo</string></value></member><member><name>b</name><value><boolean>1</boolean></value></member></struct>", "Structs convert to XML")
    }
    
    func testPrinterDateTime() {
        let components = NSDateComponents()
        components.timeZone = NSCalendar.currentCalendar().timeZone
        components.day = 17
        components.month = 7
        components.year = 1998
        components.hour = 14
        components.minute = 8
        components.second = 55
        let calendar = NSCalendar(identifier: NSGregorianCalendar)!
        calendar.timeZone = NSCalendar.currentCalendar().timeZone
        let date = calendar.dateFromComponents(components)
        let dateNode = XMLRPCParam.XDateTime(date!)
        XCTAssertEqual(dateNode.toXMLNode().description, "<dateTime.iso8601>19980717T14:08:55</dateTime.iso8601>", "ISO Dates convert to XML")
    }

    
    func testParserFault() {
        let response = "<?xml version=\"1.0\"?>" +
        "<methodResponse><fault><value><struct>" +
        "<member><name>faultCode</name><value><int>4</int></value></member>" +
        "<member><name>faultString</name><value><string>Too many parameters.</string></value></member>" +
        "</struct></value></fault></methodResponse>"
        let result = XMLRPCParser().from(string : response)
        result.cata ({s -> Void in
            XCTFail("Can parse fault responses")
            return
        },
        {error in
            XCTAssert(error.code == 4 && error.localizedDescription == "Too many parameters.", "Can parse fault responses")
            return
        })
    }
    
    func successResponse(#body : String) -> String {
        return "<?xml version=\"1.0\"?>" +
        "<methodResponse><params><param><value>\(body)</value></param></params></methodResponse>"
    }
    
    func responseParserTest(#body : String) {
        let response = successResponse(body:body)
        let result = XMLRPCParser().from(string : response)
        result.cata ({params -> Void in
            XCTAssert(countElements(params) == 1, "Expecting a single response param")
            XCTAssertEqual(params[0].toXMLNode().description, body, "Can parse a struct response")
            return
        }, {_ in
            XCTFail("Can parse fault responses")
            return
        })
    }
    
    func testParserStringResponse() {
        let body = "<string>foo</string>"
        responseParserTest(body: body)
    }
    
    func testParserIntResponse() {
        let body = "<string>foo</string>"
        responseParserTest(body: body)
    }
    
    func testParserDoubleResponse() {
        let body = "<double>3.1</double>"
        responseParserTest(body: body)
    }
    
    func testParserBooleanResponse() {
        let body = "<boolean>0</boolean>"
        responseParserTest(body: body)
    }
    
    func testParserBase64Response() {
        let body = "<base64>AAAA</base64>"
        responseParserTest(body: body)
    }
    
    func testParserDateResponse() {
        let body = "<dateTime.iso8601>19980717T14:08:55</dateTime.iso8601>"
        responseParserTest(body: body)
    }
    
    func testParserArrayResponse() {
        let body = "<array><data><value><string>foo</string></value><value><string>bar</string></value></data></array>"
        responseParserTest(body : body)
    }
    
    func testParserStructResponse() {
        let body = "<struct><member><name>foo></name><value><string>bar</string></value></member><member><name>quux</name><value><string>bar</string></value></member></struct>"
        responseParserTest(body : body)
    }
    
    func testRequestSetup() {
        let expectedResult : NSString = "<methodCall><methodName>A.B.C</methodName><params><param><value><string>foo</string></value></param></params></methodCall>"
        let request = NSMutableURLRequest(URL: NSURL(scheme: "http", host: "test", path: "/test")!)
        request.setupXMLRPCCall(path: "A.B.C", parameters: [XMLRPCParam.XString("foo")])
        XCTAssertEqual(request.HTTPMethod, "POST", "XMLRPC calls are POST calls")
        XCTAssertEqual(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!, expectedResult, "Request should be packaged correctly")
    }
}


