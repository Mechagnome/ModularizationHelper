//
//  Attribute.swift
//  SourceTool
//
//  Created by Ray Jiang on 2021/9/29.
//

import Foundation
import SwiftyJSON

class AttributeObject {
    
    let attribute: Attribute
    let offset: Int
    let length: Int
    
    init(json: JSON) {
        self.attribute = Attribute(json["key.attribute"].stringValue)
        self.offset = json["key.offset"].intValue
        self.length = json["key.length"].intValue
    }
}

enum Attribute {
    
    case NSManaged
    case UIApplicationMain
    case available
    case convenience
    case discardableResult
    case dynamic
    case `fileprivate`
    case final
    case ibaction
    case ibinspectable
    case iboutlet
    case `internal`
    case lazy
    case mutating
    case objc
    case objc_name
    case open
    case optional
    case override
    case `private`
    case `public`
    case required
    case `setter_access_fileprivate`
    case `setter_access_private`
    case weak
    
    init(_ value: String) {
        switch value {
        case "source.decl.attribute.NSManaged":
            self = .NSManaged
        case "source.decl.attribute.UIApplicationMain":
            self = .UIApplicationMain
        case "source.decl.attribute.available":
            self = .available
        case "source.decl.attribute.convenience":
            self = .convenience
        case "source.decl.attribute.discardableResult":
            self = .discardableResult
        case "source.decl.attribute.dynamic":
            self = .dynamic
        case "source.decl.attribute.fileprivate":
            self = .fileprivate
        case "source.decl.attribute.final":
            self = .final
        case "source.decl.attribute.ibaction":
            self = .ibaction
        case "source.decl.attribute.ibinspectable":
            self = .ibinspectable
        case "source.decl.attribute.iboutlet":
            self = .iboutlet
        case "source.decl.attribute.internal":
            self = .internal
        case "source.decl.attribute.lazy":
            self = .lazy
        case "source.decl.attribute.mutating":
            self = .mutating
        case "source.decl.attribute.objc":
            self = .objc
        case "source.decl.attribute.objc.name":
            self = .objc_name
        case "source.decl.attribute.open":
            self = .open
        case "source.decl.attribute.optional":
            self = .optional
        case "source.decl.attribute.override":
            self = .override
        case "source.decl.attribute.private":
            self = .private
        case "source.decl.attribute.public":
            self = .public
        case "source.decl.attribute.required":
            self = .required
        case "source.decl.attribute.setter_access.fileprivate":
            self = .setter_access_fileprivate
        case "source.decl.attribute.setter_access.private":
            self = .setter_access_private
        case "source.decl.attribute.weak":
            self = .weak
        default:
            print("⚠️ Find new Attribute:\(value)")
            fatalError()
        }
    }
}
