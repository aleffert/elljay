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
    
    func testHeader() {
        let parser = XMLParser()
        let string = "<?xml version = \"1.0\" ?><html></html>";
        let result = parser.parse(string)
        switch result {
        case let .Success(document):
            XCTAssertEqual(document.description, string, "Header should propagate")
        case let .Failure(error):
            XCTFail(error)
        }
    }
    
    func testAttributes() {
        let parser = XMLParser()
        let string = "<?xml version = \"1.0\" ?><html bar = \"a\" foo = \"b\"></html>";
        let result = parser.parse(string)
        switch result {
        case let .Success(document):
            XCTAssertEqual(document.description, string, "Attributes should save")
        case let .Failure(error):
            XCTFail(error)
        }
    }
    
    func testInnerText() {
        let parser = XMLParser()
        let string = "<?xml version = \"1.0\" ?><html bar = \"a\" foo = \"b\"><head>abc</head><body></body></html>";
        let result = parser.parse(string)
        switch result {
        case let .Success(document):
            XCTAssertEqual(document.description, string, "Inner text should propagate")
        case let .Failure(error):
            XCTFail(error)
        }
    }
    
    func testNesting() {
        let parser = XMLParser()
        let string = "<?xml version = \"1.0\" ?><html bar = \"a\" foo = \"b\"><head></head><body><div></div></body></html>";
        let result = parser.parse(string)
        switch result {
        case let .Success(document):
            XCTAssertEqual(document.description, string, "Nodes should nest")
        case let .Failure(error):
            XCTFail(error)
        }
    }
}
