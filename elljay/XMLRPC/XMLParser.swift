//
//  XMLParser.swift
//  elljay
//
//  Created by Akiva Leffert on 8/25/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation
import UIKit

private class XMLParserState {
    
    init(name : String, attributes : [String:String] = [:]) {
        self.name = name
        self.attributes = attributes
    }
    
    let attributes : [String:String]
    let name : String
    var children : [XMLNode] = []
    var text : String?
}

public enum XMLParserResult {
    case Success(XMLDocument)
    case Failure(String)
}

public class XMLParser: NSObject, NSXMLParserDelegate {
    
    private var stack : [XMLParserState] = []
    private var current : XMLParserState = XMLParserState(name: "root")
    private var failed : String?
    
    
    public func parse(string : String) -> XMLParserResult {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
        return parse(data)
    }
    
    public func parse(data : NSData) -> XMLParserResult {
        stack = []
        current = XMLParserState(name: "root")
        
        let parser = NSXMLParser(data : data)!
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
        
        if(failed != nil) { return }
        
        stack.append(current)
        current = XMLParserState(name: elementName, attributes: attributeDict as [String : String])
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)  {
        if(failed != nil) { return }
        
        if(elementName != current.name) {
            failed = "Closing element didn't match"
            return
        }
        
        let node = XMLNode(name: current.name, attributes: current.attributes, children: current.children, text: current.text)
        current = stack.removeLast()
        current.children.append(node)
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!)  {
        if(failed != nil) { return }
        if let curText = current.text {
            current.text = current.text! + string
        }
        else {
            current.text = string
        }
    }
}
