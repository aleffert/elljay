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
    
    init(name : String, attributes: [String:String] = [:], children c : [XMLNode] = [], text : String? = nil) {
        self.name = name
        self.attributes = attributes
        self.children = c
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
        let text = innerText ?? ""
        let attributeText = attributeString != nil ? " " + attributeString! : ""
        return "<\(name)\(attributeText)>\(childrenString)\(text)</\(name)>"
    }
    
    func child(name : String) -> XMLNode? {
        for child in self.children {
            if child.name == name {
                return child
            }
        }
        return nil
    }
    
    func select(tag : String, child : String, value : String) -> XMLNode? {
        let matching = all(tag)
        for match in matching {
            if let foundChild = match.child(child) {
                if foundChild.innerText == value {
                    return match
                }
            }
        }
        return nil
    }
    
    func all(tag : String) -> [XMLNode] {
        return self.children.filter {child in
            return child.name == tag
        }
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

