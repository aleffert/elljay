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
public enum XMLRPCParam {
    case XArray([XMLRPCParam])
    case XStruct([String:XMLRPCParam])
    case XInt(Int32)
    case XDouble(Double)
    case XBoolean(Bool)
    case XString(String)
    case XDateTime(NSDate)
    case XData(NSData)
}


extension XMLRPCParam {
    func arrayBody() -> [XMLRPCParam]? {
        switch(self) {
            case let XArray(a): return a
            default: return nil
        }
    }

    func structBody() -> [String:XMLRPCParam]? {
        switch(self) {
            case let XStruct(d): return d
            default: return nil
        }
    }

    func intBody() -> Int32? {
        switch(self) {
            case let XInt(i): return i
            default: return nil
        }
    }

    func doubleBody() -> Double? {
        switch(self) {
            case let XDouble(d): return d
            default: return nil
        }
    }
    
    func booleanBody() -> Bool? {
        switch(self) {
            case let XBoolean(b): return b
            default: return nil
        }
    }

    func stringBody() -> String? {
        switch(self) {
            case let XString(s): return s
            // Some service formatters are dumb and will convert things that
            // look like ints to ints even when they're just strings
            case let XInt(i): return toString(i)
            default: return nil
        }
    }

    func dateTimeBody() -> NSDate? {
        switch(self) {
            case let XDateTime(d): return d
            default: return nil
        }
    }


    func dataBody() -> NSData? {
        switch(self) {
            case let XData(d): return d
            default: return nil
        }
    }
}

extension XMLRPCParam {
    private func escape(#XMLBody : String) -> String {
        return XMLBody
            .stringByReplacingOccurrencesOfString("&", withString: "&amp;")
            .stringByReplacingOccurrencesOfString("<", withString: "&lt;")
    }
    
    public func toXMLNode() -> XMLNode {
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
        case let .XData(d):
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
    
    public func toResponseData() -> NSData! {
        //<methodResponse><params><param><value><struct>
        let node = self.toXMLNode()
        let root = XMLNode(
            name : "methodResponse",
            children : [
                XMLNode(name : "params", children : [
                    XMLNode(name : "param", children : [
                        XMLNode(name : "value", children : [
                            node
                            ])
                        ])
                    ])
            ])
        return root.description.dataUsingEncoding(NSUTF8StringEncoding)
    }
}

public typealias XMLRPCParseResult = Result<[XMLRPCParam]>

// TODO change to a class variable once they're supported
public let XMLRPCParserErrorDomain = "com.akivaleffert.elljay.XMLRPC"

public class XMLRPCParser {
    
    public init() {
        
    }

    private func malformedResponseError() -> XMLRPCParseResult {
        return Failure(NSError(domain: XMLRPCParserErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "Returned XML is not a valid XML-RPC response"]))
    }
    
    public func from(#string : String) -> XMLRPCParseResult {
        return from(data : string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    public func from(#data : NSData) -> XMLRPCParseResult {
        let parser = XMLParser()
        let parseResult = parser.parse(data)
        
        return parseResult.bind {
            return self.from(XMLDocument : $0)
        }
    }
    
    private func from(XMLDocument document : XMLDocument) -> XMLRPCParseResult {
        if(document.body.count != 1) {
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
        
    private func process(#param : XMLNode) -> XMLRPCParam? {
        let value = param.child("value")
        if let v = value {
            return process(value : v)
        }
        return nil
    }

    private func processParamNodes(nodes : [XMLNode]) -> [XMLRPCParam]? {
        return nodes.mapOrFail {s in return self.process(param : s)}
    }
    
    private func from(paramNodes params : XMLNode) -> XMLRPCParseResult {
        let items : [XMLNode]? = params.all("param")
        return items.bind {i in
            return self.processParamNodes(i)
        }.bind {(r : [XMLRPCParam]) in
            return Success(r)
        } ?? malformedResponseError()
    }


    private func process(value v : XMLNode) -> XMLRPCParam? {
        if v.children.count != 1 {
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
            return data.map {XMLRPCParam.XData($0) }
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
    
    private func process(#arrayNode : XMLNode) -> XMLRPCParam? {
        let children : [XMLNode]? = arrayNode.child("data")?.children
        let params : [XMLRPCParam]? = children.bind {cs in
            let result : [XMLRPCParam]? = cs.mapOrFail {c in return self.process(value : c)}
            return result
        }
        let result : XMLRPCParam? = params.bind {p in
            return XMLRPCParam.XArray(p)
        }
        return result
    }

    private func process(#structMemberNode : XMLNode) -> (String, XMLRPCParam)? {
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

    private func process(#structureNode : XMLNode) -> XMLRPCParam? {
        let children = structureNode.all("member")
        return children.mapOrFail {m in self.process(structMemberNode : m)}
        .bind {(d : [(String, XMLRPCParam)]) in
            return XMLRPCParam.XStruct(Dictionary.fromArray(d))
        }
    }
    
    private func from(#faultNodes : XMLNode) -> XMLRPCParseResult {
        let faultCodeMember = faultNodes.child("value")?.child("struct")?.select("member", child : "name", value : "faultCode")
        let faultReasonMember = faultNodes.child("value")?.child("struct")?.select("member", child : "name", value : "faultString")
        let faultCode : Int? = faultCodeMember?.child("value")?.child("int")?.innerText.bind {s in return s.toInt()}
        let faultReason : String? = faultReasonMember?.child("value")?.child("string")?.innerText
        if faultCode != nil && faultReason != nil {
            let error = NSError(domain: XMLRPCParserErrorDomain, code: faultCode!, userInfo: [NSLocalizedDescriptionKey : faultReason!])
            return Failure(error)
        }
        else {
            return malformedResponseError()
        }
    }
}

private let XMLRPCMethodName = "XMLRPCMethod" // Purely for our convenience for stubbing
extension NSMutableURLRequest {
    
    internal func body(#path : String, parameters : [XMLRPCParam]) -> NSData {
        let methodNameNode = XMLNode(name: "methodName", children: [], text: path)
        let paramNodes : [XMLNode] = parameters.map {param in XMLNode(name: "value", children: [param.toXMLNode()])}
        let paramNode = XMLNode(name : "param", children : paramNodes)
        let paramsNode = XMLNode(name : "params", children : [paramNode])
        let node = XMLNode(name: "methodCall", children: [methodNameNode, paramsNode])
        
        return NSData(data: node.description.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    public func setupXMLRPCCall(#path : String, parameters : [XMLRPCParam]) {
        self.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        self.HTTPMethod = "POST"
        self.HTTPBody = body(path : path, parameters : parameters)
        self.addValue(path, forHTTPHeaderField: XMLRPCMethodName)
    }

}

extension NSURLRequest {
    public func XMLRPCMethod() -> String? {
        let method = self.allHTTPHeaderFields?[XMLRPCMethodName] as? String
        return method
    }
}