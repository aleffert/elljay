//
//  XMLParser.swift
//  elljay
//
//  Created by Akiva Leffert on 8/25/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit

class XMLParserState {
    
    init(name : String, attributes : [String:String] = [:]) {
        self.name = name
        self.attributes = attributes
    }
    
    let attributes : [String:String]
    let name : String
    var children : [XMLNode] = []
    var text : String?
}

enum XMLParserResult {
    case Success(XMLDocument)
    case Failure(String)
}

class XMLParser: NSObject, NSXMLParserDelegate {
    var stack : [XMLParserState] = []
    var current : XMLParserState = XMLParserState(name: "root")
    var failed : String?
    
    func parse(string : String) -> XMLParserResult {
        stack = []
        current = XMLParserState(name: "root")
        
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let parser = NSXMLParser(data : data)
        parser.delegate = self
        parser.parse()
        if let error = parser.parserError {
            return XMLParserResult.Failure(error.localizedDescription)
        }
        else if let reason = failed {
            return XMLParserResult.Failure(reason)
        }
        else {
            return XMLParserResult.Success(XMLDocument(current.children))
        }
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)  {
        
        if(failed) { return }
        
        stack.append(current)
        current = XMLParserState(name: elementName, attributes: attributeDict as [String : String])
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)  {
        if(failed) { return }
        
        if(elementName != current.name) {
            failed = "Closing element didn't match"
            return
        }
        
        let node = XMLNode(name: current.name, attributes: current.attributes, children: current.children, text: current.text)
        current = stack.removeLast()
        current.children.append(node)
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!)  {
        if(failed) { return }
        if let curText = current.text {
            current.text = current.text! + string
        }
        else {
            current.text = string
        }
    }
}
