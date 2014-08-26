//
//  XMLNode.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

class XMLNode : Printable {
    let name : String
    let attributes : [String:String]
    let children : [XMLNode]
    let innerText : String?
    
    init(name : String, attributes: [String:String] = [:], children : [XMLNode] = [], text : String? = nil) {
        self.name = name
        self.children = children
        self.attributes = attributes;
        self.innerText = text
    }
    
    var description : String {
        let attributePairs : [String] = sortedMap(attributes) {key, value in
            return "\(key) = \"\(value)\""
        }
        let attributeString = reduce1(attributePairs) {acc, cur in
            return acc + " " + cur
        }
        let childrenStrings = children.map {node in node.description}
        let childrenString = reduce(childrenStrings, "", {acc, cur in return acc + cur})
        let text = innerText ? innerText! : ""
        let attributeText = attributeString ? " " + attributeString! : ""
        return "<\(name)\(attributeText)>\(childrenString)\(text)</\(name)>"
    }
}

class XMLDocument : Printable {
    
    init(_ body : [XMLNode]) {
        self.body = body
    }
    
    let body : [XMLNode]
    
    var description : String {
    let bodyString = reduce(body, "") {acc, cur in return acc + cur.description}
        return "<?xml version = \"1.0\" ?>\(bodyString)"
    }
}

