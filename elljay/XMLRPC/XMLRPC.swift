//
//  XMLRPC.swift
//  elljay
//
//  Created by Akiva Leffert on 8/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

import Foundation

let ISO8601FormatString = "yyyyMMdd'T'HH:mm:ss"

extension NSDate {
    
    func toISO8601String () -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = ISO8601FormatString
        return formatter.stringFromDate(self)
    }
    
    class func fromISO8601String (s : String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = ISO8601FormatString
        return formatter.dateFromString(s)
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
}

extension XMLRPCParam {
    func escape(#XMLBody : String) -> String {
        return XMLBody
            .stringByReplacingOccurrencesOfString("&", withString: "&amp;")
            .stringByReplacingOccurrencesOfString("<", withString: "&lt;")
    }
    
    func toXMLNode() -> XMLNode {
        switch self {
        case let .XInt(i):
            return XMLNode(name: "int", children : [], text: String(i))
        case let .XDouble(d):
            assert(!isinf(d), "Only numeric values supported")
            assert(!isnan(d), "Only numeric values supported")
            return XMLNode(name : "double", children : [], text : NSString(format : "%.15lf", d).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "0")))
        case let .XBoolean(b):
            return XMLNode(name : "boolean", children : [], text : b ? "1" : "0")
        case let .XString(s):
            return XMLNode(name : "string", children : [], text : escape(XMLBody : s))
        case let .XBase64Data(d):
            let base64 = d.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
            return XMLNode(name : "base64", children : [], text : base64)
        case let .XArray(ps):
            let children = ps.map {param in XMLNode(name:"value", children:[param.toXMLNode()])}
            return XMLNode(name : "array", children : [XMLNode(name: "data", children: children)])
        case let .XStruct(ms):
            let members : [XMLNode] = sortedMap(ms) {key, value in
                let nameNode = XMLNode(name: "name", children : [], text: key)
                let valueNode = XMLNode(name: "value", children: [value.toXMLNode()])
                return XMLNode(name : "member", children: [nameNode, valueNode])
            }
            return XMLNode(name: "struct", children: members)
        case let .XDateTime(date):
            return XMLNode(name : "dateTime.iso8601", children : [], text : date.toISO8601String())
        }
    }
}

enum XMLRPCResult {
    case Response([XMLRPCParam])
    case Fault(Int, String)
    case ParseError(String)
}

extension XMLRPCResult {
    
    static func malformedResponseError() -> XMLRPCResult {
        return ParseError("Returned XML is not an XML-RPC ")
    }
    
    static func from(#string : String) -> XMLRPCResult {
        return from(data : string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    }
    
    static func from(#data : NSData) -> XMLRPCResult {
        let parser = XMLParser()
        let parseResult = parser.parse(data)
        
        switch(parseResult) {
        case let .Failure(error):
            return ParseError(error)
        case let .Success(document):
            return from(XMLDocument : document)
        }
    }
    
    static func from(XMLDocument document : XMLDocument) -> XMLRPCResult {
        if(countElements(document.body) != 1) {
            return malformedResponseError()
        }
        
        let body = document.body[0]
        if(body.children.count != 1 || body.name != "methodResponse") {
            return malformedResponseError()
        }
        
        if let params = body.child("params") {
            return from(paramNodes : params)
        }
        else if let failure = body.child("fault") {
            return from(faultNodes : failure)
        }
        else  {
            return malformedResponseError()
        }
        
    }
        
    static func process(#param : XMLNode) -> XMLRPCParam? {
        let value = param.child("value")
        if let v = value {
            return process(value : v)
        }
        return nil
    }

    static func processParamNodes(nodes : [XMLNode]) -> [XMLRPCParam]? {
        return mapOrFail(nodes, {s in self.process(param : s)})
    }
    
    static func from(paramNodes params : XMLNode) -> XMLRPCResult {
        let items : [XMLNode]? = params.all("param")
        return items.bind {i in
            return self.processParamNodes(i)
        }.bind {(r : [XMLRPCParam]) in
            return Response(r)
        } ?? malformedResponseError()
    }


    static func process(value v : XMLNode) -> XMLRPCParam? {
        if countElements(v.children) != 1 {
            return nil
        }
        let body = v.children[0]

        let inner = body.innerText ?? ""
        
        switch(body.name) {
        case "string":
            return XMLRPCParam.XString(inner)
        case "int", "i4":
            if let b = inner.toInt() {
                return XMLRPCParam.XInt(Int32(b))
            }
            else {
                return nil
            }
        case "double":
            let formatter = NSNumberFormatter()
            let number = formatter.numberFromString(inner)
            if let n = number {
                return XMLRPCParam.XDouble(n.doubleValue)
            }
            else {
                return nil
            }
        case "boolean":
            switch(inner) {
            case "0":
                return XMLRPCParam.XBoolean(false)
            case "1":
                return XMLRPCParam.XBoolean(true)
            default:
                return nil
            }
        case "base64":
            let data = NSData(base64EncodedString: inner, options: NSDataBase64DecodingOptions())
            return XMLRPCParam.XBase64Data(data)
        case "dateTime.iso8601":
            let date = NSDate.fromISO8601String(inner)
            return date == nil ? nil : XMLRPCParam.XDateTime(date!)
        case "array":
            return process(arrayNode : body)
        case "struct":
            return process(structureNode : body)
        default:
            return nil
        }
    }
    
    static func process(#arrayNode : XMLNode) -> XMLRPCParam? {
        let children : [XMLNode]? = arrayNode.child("data")?.children
        let params : [XMLRPCParam]? = children.bind {cs in
            let result : [XMLRPCParam]? = mapOrFail(cs) {c in return self.process(value : c)}
            return result
        }
        let result : XMLRPCParam? = params.bind {p in
            return XMLRPCParam.XArray(p)
        }
        return result
    }

    static func process(#structMemberNode : XMLNode) -> (String, XMLRPCParam)? {
        let name = structMemberNode.child("name")
        let value = structMemberNode.child("value")
        if name?.innerText == nil {
            return nil
        }
        let v : XMLRPCParam? = value.bind { v in return self.process(value : v)}
        let result : (String, XMLRPCParam)? = v.bind { v in
            return (name!.innerText!, v)
        }
        return result
    }

    static func process(#structureNode : XMLNode) -> XMLRPCParam? {
        let children = structureNode.all("member")
        return mapOrFail(children, {m in self.process(structMemberNode : m)})
        .bind {(d : [(String, XMLRPCParam)]) in
            return XMLRPCParam.XStruct(Dictionary.fromArray(d))
        }
    }
    
    static func from(#faultNodes : XMLNode) -> XMLRPCResult {
        let faultCodeMember = faultNodes.child("value")?.child("struct")?.select("member", child : "name", value : "faultCode")
        let faultReasonMember = faultNodes.child("value")?.child("struct")?.select("member", child : "name", value : "faultString")
        let faultCode : Int? = faultCodeMember?.child("value")?.child("int")?.innerText.bind {s in return s.toInt()}
        let faultReason : String? = faultReasonMember?.child("value")?.child("string")?.innerText

        if faultCode != nil && faultReason != nil {
            return Fault(faultCode!, faultReason!)
        }
        else {
            return malformedResponseError()
        }
    }
}

extension NSMutableURLRequest {
    
    internal func body(#path : String, parameters : [XMLRPCParam]) -> NSData {
        let methodNameNode = XMLNode(name: "methodName", children: [], text: path)
        let paramNodes : [XMLNode] = parameters.map {param in param.toXMLNode()}
        let paramsNode = XMLNode(name : "params", children : paramNodes)
        let node = XMLNode(name: "methodCall", children: [methodNameNode, paramsNode])
        
        return NSData()
    }
    
    func setupXMLRPCCall(#path : String, parameters : [XMLRPCParam]) {
        self.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        self.HTTPMethod = "POST"
        self.HTTPBody = body(path : path, parameters : parameters)
    }
}
