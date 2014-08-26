//
//  XMLRPCRequest.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

extension NSDate {
    func toISO8601String () -> NSString {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HH:mm:ss"
        return formatter.stringFromDate(self)
    }
}

// Use X so as not to interfere with built in type names
enum XMLRPCParam {
    case XArray([XMLRPCParam])
    case XStruct([String:XMLRPCParam])
    case XInt(Int32)
    case XDouble(Double)
    case XBoolean(Bool)
    case XString(String)
    case XDateTime(NSDate)
    case XBase64Data(NSData)
    
    func escapeForXMLBody(s : String) -> String {
        return s
            .stringByReplacingOccurrencesOfString("&", withString: "&amp;")
            .stringByReplacingOccurrencesOfString("<", withString: "&lt;")
    }
    
    func toXMLNode() -> XMLNode {
        switch self {
        case let .XInt(i):
            return XMLNode(name: "int", text: String(i))
        case let .XDouble(d):
            assert(!isinf(d), "Only numeric values supported")
            assert(!isnan(d), "Only numeric values supported")
            return XMLNode(name : "double", text : NSString(format : "%.15lf", d).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0")))
        case let .XBoolean(b):
            return XMLNode(name : "boolean", text : b ? "1" : "0")
        case let .XString(s):
            return XMLNode(name : "string", text : escapeForXMLBody(s))
        case let .XBase64Data(d):
            let base64 = d.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
            return XMLNode(name : "base64", text : base64)
        case let .XArray(ps):
            let children = ps.map {param in XMLNode(name:"value", children:[param.toXMLNode()])}
            return XMLNode(name : "array", children : [XMLNode(name: "data", children: children)])
        case let .XStruct(ms):
            let members : [XMLNode] = sortedMap(ms) {key, value in
                let nameNode = XMLNode(name: "name", text: key)
                let valueNode = XMLNode(name: "value", children: [value.toXMLNode()])
                return XMLNode(name : "member", children: [nameNode, valueNode])
            }
            return XMLNode(name: "struct", children: members)
        case let .XDateTime(date):
            return XMLNode(name : "dateTime.iso8601", text : date.toISO8601String())
        }
    }
}

struct XMLRPCFault {
    let code : Int
    let message : String
}

enum XMLRPCResult {
    case XResponse([XMLRPCParam])
    case XFault(XMLRPCFault)
}


extension String {
    static func toXMLRPCResult() -> XMLRPCResult {
        return XMLRPCResult.XFault(XMLRPCFault(code : 0, message : "unimp"))
    }
}

extension NSMutableURLRequest {
    
    internal func bodyForPath(path : String, parameters : [XMLRPCParam]) -> NSData {
        let methodNameNode = XMLNode(name: "methodName", text: path)
        let paramNodes : [XMLNode] = parameters.map {param in param.toXMLNode()}
        let paramsNode = XMLNode(name : "params", children : paramNodes)
        let node = XMLNode(name: "methodCall", children: [methodNameNode, paramsNode])
        
        return NSData()
    }
    
    func setupXMLRPCCallWithPath(path : String, parameters : [XMLRPCParam]) {
        self.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        self.HTTPMethod = "POST"
        self.HTTPBody = bodyForPath(path, parameters : parameters)
    }
}