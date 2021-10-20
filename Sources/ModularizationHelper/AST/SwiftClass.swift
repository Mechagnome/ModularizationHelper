//
//  SwiftClass.swift
//  SourceTool
//
//  Created by Ray Jiang on 2021/9/29.
//

import Foundation
import SwiftyJSON

var objectMap: [String: SwiftObject] = [:]

class SwiftObject {
    
    let kind: Kind
    let name: String
    let offset: Int
    let length: Int
    let nameoffset: Int
    let namelength: Int
    let inheritedtypes: [String]
    let accessibility: Accessibility
    let attributeOffset: Int
    let attributes: [AttributeObject]
    let substructure: [SwiftObject]
    
    let rawValue: JSON
    weak var parent: SwiftObject?
    
    /// 隐式 internal
    var implicitInternal: Bool {
        return accessibility == .internal && attributes.filter { $0.attribute == .internal }.isEmpty
    }
    
    var parentIsPrivate: Bool {
        if let obj = parent {
            return obj.accessibility.isPrivate
        }
        return false
    }
    
    init(json: JSON) {
        self.rawValue = json
        self.kind = Kind(json["key.kind"].stringValue)
        self.name = json["key.name"].stringValue
        self.offset = json["key.offset"].intValue
        self.length = json["key.length"].intValue
        self.nameoffset = json["key.nameoffset"].intValue
        self.namelength = json["key.namelength"].intValue
        self.accessibility = Accessibility(json["key.accessibility"].stringValue)
        self.inheritedtypes = json["key.inheritedtypes"].arrayValue.map { $0["key.name"].stringValue }
        
        self.attributes = json["key.attributes"].arrayValue.map { AttributeObject(json: $0) }
        
        var startOffset = Int.max
        for attribute in attributes {
            switch attribute.attribute { // 跳过以下关键字，public 不能加在 @xxx 前面
            case .discardableResult, .objc, .available, .iboutlet, .ibaction, .ibinspectable:
                continue
            default:
                break
            }
            startOffset = min(startOffset, attribute.offset)
        }
        self.attributeOffset = startOffset == Int.max ? json["key.offset"].intValue : startOffset
        
        var list: [SwiftObject] = []
        for substructure in json["key.substructure"].arrayValue {
            let kind = Kind(substructure["key.kind"].stringValue)
            switch kind {
            case .varClass, .varStatic, .varGlobal, .varInstance:
                list.append(SwiftProperty(json: substructure))
            case .funcClass, .funcStatic, .funcInstance, .funcSubscript:
                list.append(SwiftFunction(json: substructure))
            default:
                list.append(SwiftObject(json: substructure))
            }
        }
        self.substructure = list
        
        setup()
    }
    
    func setup() {
        for subObj in substructure {
            subObj.parent = self
        }
    }
}

class SwiftFunction: SwiftObject {

    let bodyoffset: Int
    let bodylength: Int
    
    let returnType: String

    override init(json: JSON) {
        self.bodyoffset = json["key.bodyoffset"].intValue
        self.bodylength = json["key.bodylength"].intValue
        self.returnType = json["key.typename"].string ?? "Void"
        super.init(json: json)
    }
}

class SwiftProperty: SwiftObject {
    
    let setter_accessibility: Accessibility
    
    override init(json: JSON) {
        self.setter_accessibility = Accessibility(json["key.setter_accessibility"].string ?? json["key.accessibility"].stringValue)
        super.init(json: json)
    }
}
