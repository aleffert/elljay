//
//  XMLParserTests.swift
//  elljay
//
//  Created by Akiva Leffert on 8/25/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import UIKit
import XCTest

// TODO: Tests that should cause parse errors

class XMLParserTests: XCTestCase {
    
    func makeParserTest(#body : String, message : String) {
        let parser = XMLParser()
        let string = "<?xml version = \"1.0\" ?>\(body)";
        let result = parser.parse(string)
        result.cata ({(d : XMLDocument) in
            XCTAssertEqual(d.description, string, message)
            return
        }, {
            XCTFail("Error: \($0)")
        })
    }
    
    func testHeader() {
        makeParserTest(
            body : "<html></html>",
            message : "Header should propagate")
    }
    
    func testAttributes() {
        makeParserTest(
            body : "<html bar = \"a\" foo = \"b\"></html>",
            message : "Attributes should save")
    }
    
    func testInnerText() {
        makeParserTest(
            body : "<html bar = \"a\" foo = \"b\"><head>abc</head><body></body></html>",
            message : "Inner text should propagate")
    }
    
    func testNesting() {
        makeParserTest(
            body : "<html bar = \"a\" foo = \"b\"><head></head><body><div></div></body></html>",
            message : "Nodes should nest")
    }
}
