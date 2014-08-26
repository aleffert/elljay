//
//  XMLNodeTests.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import XCTest

class XMLNodeTests : XCTestCase {

    func testNode() {
        let node = XMLNode(name : "foo")
        XCTAssertEqual(node.description, "<foo></foo>", "Node have names")
    }
    
    func testAttributes() {
        let node = XMLNode(name : "foo", attributes : ["foo" : "bar", "baz" : "quux", "abc" : "def"])
        XCTAssertEqual(node.description, "<foo abc = \"def\" baz = \"quux\" foo = \"bar\"></foo>", "Node have attributes")
    }
    
    func testChildren() {
        let child1 = XMLNode(name : "bar")
        let child2 = XMLNode(name : "baz")
        let node = XMLNode(name : "foo", children : [child1, child2])
        XCTAssertEqual(node.description, "<foo><bar></bar><baz></baz></foo>", "Nodes have children")
    }
    func testInnerText() {
        let node = XMLNode(name: "foo", text : "bar")
        XCTAssertEqual(node.description, "<foo>bar</foo>", "Nodes have inner text")
    }
    
    func testAll() {
        let child = XMLNode(name : "p", text : "hi!")
        let node = XMLNode(name: "div", attributes: ["class" : "test", "id" : "test"], children: [child, child], text: "Test")
        XCTAssertEqual(node.description, "<div class = \"test\" id = \"test\"><p>hi!</p><p>hi!</p>Test</div>", "Using all features works properly")
    }
}
